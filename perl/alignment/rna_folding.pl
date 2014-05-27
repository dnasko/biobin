#!/usr/bin/perl
use strict;

my @S; ## holds input string, split into single chars.
my @C; ## holds dynamic programming table.
       ## number of hydrogen bonds different base pairs can form
my %Bonds = (
    GU => 1,
    UG => 1,
    AU => 2,
    UA => 2,
    CG => 3,
    GC => 3
    );
my $seq = $ARGV[0];
$seq =~ tr/atgcT/AUGCU/;
FoldRna($seq);
print TraceBack(1, length $seq), "\n";

# my $infile = $ARGV[0];
# my $header;
# open(IN,"<$infile") || die "\n Cannot open the infile: $infile\n";
# while(<IN>) {
#     chomp;
#     if ($_ =~ m/^>/) {
# 	$header = $_;
# 	$header =~ s/^>//;
#     }
#     else {
# 	my $seq = $_;
# 	$seq =~ tr/atgcT/AUGCU/;
# 	FoldRna($seq);
# 	print TraceBack(1, length $seq), "\n";
#     }
# }
# close(IN);


## Subroutines
## Max
## RETURNS: the larger of its two arguments.
sub Max
{
    my($x,$y) = @_;
    if ($x > $y) { return $x; }
    else { return $y;}
}

##########
## FoldRna
## Implements the dynamic programming scheme to determine
##  the maximum number of hydrogen bonds that can be formed
##  by folding an RNA string.
## RETURNS: nothing; fills @C.
sub FoldRna
{
    my ($s) = @_; ## The RNA sequence to be folded, in form of a string.
    my $slen = length $s;
    @S = ('X', split(//, $s));
    for (my $len=5; $len <= $slen; $len++) {
	for (my $i=1;$i<=$slen-$len+1; $i++) {
	    my $j = $i+$len-1;
	    $C[$i][$j] = Max($C[$i+1][$j],
	    		     $Bonds{$S[$i].$S[$j]}+$C[$i+1][$j-1]);
	    
	    for (my $k=$i+1; $k < $j; $k++) {
	    	$C[$i][$j] = Max($C[$i][$j],
	    			 $C[$i][$k]+$C[$k+1][$j]);
	    }
	}
    }
}

##########
## TraceBack
## Uses the contents of the dynamic programming table @C to
##  construct a string of parentheses and dots describing the
##  optimal folding of the RNA string @S[$i..$j]. Recursive.
## RETURNS: the string of parentheses/dots.
sub TraceBack
{
    my($i,$j) = @_;  ## left and right boundries of substring being folded.
    my $cij = $C[$i][$j];
    
    return ("." x ($j-$i+1)) if ($cij == 0);
    return "." . TraceBack($i+1,$j)
	if ($cij == $C[$i+1][$j]);
    return "(" . TraceBack($i+1,$j-1) . ")"
	if ($cij == $Bonds{$S[$i].$S[$j]}+ $C[$i+1][$j-1]);
    for (my $k = $i+1; $k < $j; $k++) {
	return TraceBack($i,$k) . TraceBack($k+1,$j)
	    if ($cij == ($C[$i][$k]+$C[$k+1][$j]));
    }
}

exit 0;
