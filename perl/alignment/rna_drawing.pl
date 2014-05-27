#!/usr/bin/perl
use strict;

my $infile = $ARGV[0];

my @structure; ## list of dots and parens describing input structures
my @bases;      ## list of bases from input string.
### Largest and smallest x- and y-coordinates used in the drawing:
###  ultimately used to scal drawing onto one page.
my ($minx,$maxx,$miny,$maxy);

my $header;
open(IN,"<$infile") || die "\n Fatal: Could no open infile: $infile\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	$header = $_;
	$header =~ s/^>//;
	open(OUT,">/Users/dnasko/Desktop/images/$header.ps") || die "\n Can't open\n";
    }
    else {
	my $seq = $_;
	$seq =~ tr/atgcT/AUGCU/;
	my $aln = `perl /Users/dnasko/GitHub/biobin/perl/alignment/rna_folding.pl $seq`;
	chomp($aln);
	drawRnaStructure($seq,$aln);
	close(OUT);
    }
}
close(IN);

## subroutines
##########
## max
## RETURNS: the larger of its two arguments.
sub max
{
    my($x,$y) = @_;
    if ($x>$y) { return $x; }
    else { return $y; }
}
##########
## begin_PostScriptPicture
## issues PostScript commands needed at beginning of .ps file.
## RETURNS: nothing.
sub begin_PostScriptPicture
{
    print OUT "/rnaline { pt setlinewidth moveto lineto stroke} def\n";
    print OUT "/rnabase { moveto -0.12 -0.12 rmoveto show} def\n";
    print OUT "/rnapicture {\n\n";
}
##########
## end_PostScriptPicture
## issues PostScript commands needed at end of .ps file.
## RETURNS: nothing.
sub end_PostScriptPicture
{
    print OUT "\n} def\n\n";
    my $scale = 0.95 * (8.5*72) / max($maxx-$minx, $maxy-$miny);
    my $xorigin = ((8.5*72) * -$minx / ($maxx-$minx))  || "0";
    my $yorigin = ((8.5*72) * -$miny / ($maxy-$miny)) || "0";
    print OUT "/pt {$scale div} def\n\n";
    print OUT "/Helvetica findfont ", 8, " pt scalefont setfont\n";
    print OUT "$xorigin $yorigin translate\n";
    print OUT "$scale dup scale\n";
    print OUT "rnapicture showpage\n";
}
##########
## drawLine
## issues PostScript commands needed to draw a line.
## RETURNS: nothing.
sub drawLine
{
    my ($x1, $y1,  ## coordinates of one endpoint                                                                                                                                                             
        $x2, $y2,  ## coordinates of other endpoint                                                                                                                                                           
        $thick     ## thickness of line                                                                                                                                                                       
        ) = @_;
    ($x1, $y1, $x2, $y2) = (0.8 * $x1 + 0.2 * $x2,
                            0.8 * $y1 + 0.2 * $y2,
                            0.2 * $x1 + 0.8 * $x2,
                            0.2 * $y1 + 0.8 * $y2);
    print OUT "$x1 $y1 $x2 $y2 $thick rnaline\n";
    ## record this info to know overall size of picture.                                                                                                                                                      
    ($x1,$x2) = ($x2,$x1) if ($x1>$x2);
    $maxx = $x2 if $x2>$maxx;
    $minx = $x1 if $x1<$minx;
    ($y1,$y2) = ($y2,$y1) if ($y1>$y2);
    $maxy = $y2 if $y2>$maxy;
    $miny = $y1 if $y1<$miny;
}
##########
## drawBase
## issues PostScript commands needed to print OUT letter for a base.
## RETURNS: nothing.
sub drawBase
{
    my ($x, $y, ## coordinates of base                                                                                                                                                                        
        $b      ## letter (character) to print OUT; can be 5 or 3                                                                                                                                                 
        ) = @_;
    $b .= "'" if ("53" =~ $b);
    print OUT "($b) $x $y rnabase\n"
}
##########
## drawRna
## assists drawRnaStructure to create PostScript drawing of RNA.
## invokes itself recursively for each ring of the structure.
## RETURNS: nothing.
sub drawRna
{
    my ($l, $r,   ## range of @structure and @bases to be drawn.                                                                                                                                              
        $lx, $ly, ## coordinates of first position of ring.                                                                                                                                                   
        $rx, $ry  ## coordinates of last position of ring.                                                                                                                                                    
        ) = @_;
    my $level=0;
    my $count=2;
    for (my $i=$l+1; $i<$r; $i++) {
        $level-- if ($structure[$i] eq ")");
        $count++ if $level==0;
        $level++ if ($structure[$i] eq "(");
    }

    my $theta = 2 * 3.14159 / $count;
    my $rad = 1 / (2*sin($theta/2));            ## radius                                                                                                                                                     
    my $h = $rad * cos($theta/2);
    my ($cx, $cy) = ((($lx+$rx)/2.0)+$h*($ly-$ry),    ## center of circle                                                                                                                                     
                     (($ly+$ry)/2.0)+$h*($rx-$lx));
    my $alpha = atan2($ly-$cy,$lx-$cx);

    my ($ii,$xx,$yy) = ($l,$lx,$ly);

    for (my $i=$l+1; $i<=$r; $i++) {
        $level-- if ($structure[$i] eq ")");
        if ($level==0) {
            $alpha -= $theta;
            my ($x,$y) = ($cx+$rad*cos($alpha), $cy+$rad*sin($alpha));
            drawLine($xx,$yy,$x,$y,0);
            drawRna($ii,$i,$xx,$yy, $x, $y) if ($structure[$i] eq ")");
            drawBase($xx,$yy, $bases[$ii]);
            ($xx,$yy)=($x,$y);
            $ii = $i;
        }
        $level++ if ($structure[$i] eq "(");
    }
    drawLine($xx,$yy,$rx,$ry,0);
    drawBase($xx,$yy, $bases[$r-1]);
    drawBase($rx,$ry, $bases[$r]);
    my %bonds = (GU=>1,UG=>1,AU=>2,UA=>2,CG=>3,GC=>3);
    drawLine($lx,$ly,$rx,$ry,$bonds{$bases[$l].$bases[$r]}+0)
        unless ($lx==0 || $ly==0);   ## 3-5 pair
}
##########
## drawRnaStructure
## creates PostScript drawing of RNA structure.
## Most of the work is delegated to the recursive subroutine drawRna.
## RETURNS: nothing.
sub drawRnaStructure
{
    my ($basestring,$structurestring) = @_;
    @bases = split(//, 5 . $basestring . 3);
    @structure = split(//, "($structurestring)");
    begin_PostScriptPicture();
    drawRna(0, $#structure, 0,0, 1,0);
    end_PostScriptPicture();
}
