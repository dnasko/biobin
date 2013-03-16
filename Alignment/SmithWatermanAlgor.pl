#!/usr/bin/perl -w

# MANUAL FOR smith_waterman.pl

=pod

=head1 NAME

smith_waterman.pl -- The Smith-Waterman algorithm for global sequence alignment

=head1 SYNOPSIS

 smith_waterman.pl --input FILENAME --output FILENAME
                     [--help] [--manual]

=head1 DESCRIPTION

Perl script implimenting the Smith-Waterman algorithm for global seqence alignment.
Adapted from a script provided by Adam Marsh.

=head1 OPTIONS

=over 3

=item B<-i, --in>=/Path/to/infile.fasta

Input file in FASTA format. (Required) 

=item B<-o, --out>=/Path/to/outfile.txt

Output file in Text format. (Required) 

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries.

Getopt::Long
File::Basename
Pod::Usage
Bio::Seq
Bio::SeqIO

=head1 AUTHOR

Written by Daniel Nasko, 
Center for Bioinformatics and Computational Biology Core Facility, University of Delaware.

=head1 REPORTING BUGS

Report bugs to dnasko@udel.edu

=head1 COPYRIGHT

Copyright 2012 Daniel Nasko.  
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  

Please acknowledge author and affiliation in published work arising from this script's 
usage <http://bioinformatics.udel.edu/Core/Acknowledge>.

=cut

use strict;
use Getopt::Long;
use File::Basename;
use Pod::Usage;
use Bio::Seq;
use Bio::SeqIO;

## Arguments with no default
my($infile,$outfile,$sequence,$help,$manual);

GetOptions (	
				"i|infile=s"	=>	\$infile,
				"o|outfile"	=>	\$outfile,
				"s|seq"		=>	\$sequence,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage(-verbose => 1)  if ($help);
pod2usage( -msg  => "\n\nERROR!  Required arguments --infile and/or --outfile and/or --seq not found.\n\nALL ARE REQUIRED\n\n", -exitval => 2, -verbose => 1)  if (! $infile && ! $outfile && ! $sequence);

my $seq1 = $sequence;

my %NTs;
my @FILE;

open(OUT,">>$outfile");

print "Enter querry sequence: ";

print OUT "Smith-Water Algorithm Analysis\nDeveloped by Temple F. Smith and Michael S. Waterman\nScript written by Dan Nasko\n\n";
print OUT "Sequence File: ";
print OUT $infile; print OUT "\n";
print OUT "Motif: ";
print OUT $seq1; print OUT "\n";
print OUT "\n+---------------+\n|Scoring Scheme\t|\n+---------------+\n|Match = +1\t|\n|Mismatch = -1\t|\n|Gap = -1\t|\n+---------------+";
print OUT "\n\n\n BEGAN ALIGNMENT AT: ";
&TimeStamp;

&ReadFasta($infile);




my $ALL_maxscore = 0;

# scoring scheme
my $MATCH    =  1; # +1 for letters that match
my $MISMATCH = -1; # -1 for letters that mismatch
my $GAP      = -1; # -1 for any gap

# initialization
foreach my $gene (keys %NTs)
{   
    my $seq2 = $NTs{$gene};
    my @matrix;
    $matrix[0][0]{score}   = 0;
    $matrix[0][0]{pointer} = "none";
    for(my $j = 1; $j <= length($seq1); $j++) {
        $matrix[0][$j]{score}   = 0;
        $matrix[0][$j]{pointer} = "none";
    }
    for (my $i = 1; $i <= length($seq2); $i++) {
        $matrix[$i][0]{score}   = 0;
        $matrix[$i][0]{pointer} = "none";
    }
    
    # fill
    my $max_i     = 0;
    my $max_j     = 0;
    my $max_score = 0;
    
    for(my $i = 1; $i <= length($seq2); $i++) {
        for(my $j = 1; $j <= length($seq1); $j++) {
            my ($diagonal_score, $left_score, $up_score);
            
            # calculate match score
            my $letter1 = substr($seq1, $j-1, 1);
            my $letter2 = substr($seq2, $i-1, 1);       
            if ($letter1 eq $letter2) {
                $diagonal_score = $matrix[$i-1][$j-1]{score} + $MATCH;
            }
            else {
                $diagonal_score = $matrix[$i-1][$j-1]{score} + $MISMATCH;
            }
            
            # calculate gap scores
            $up_score   = $matrix[$i-1][$j]{score} + $GAP;
            $left_score = $matrix[$i][$j-1]{score} + $GAP;
            
            if ($diagonal_score <= 0 and $up_score <= 0 and $left_score <= 0) {
                $matrix[$i][$j]{score}   = 0;
                $matrix[$i][$j]{pointer} = "none";
                next; # terminate this iteration of the loop
            }
            
            # choose best score
            if ($diagonal_score >= $up_score) {
                if ($diagonal_score >= $left_score) {
                    $matrix[$i][$j]{score}   = $diagonal_score;
                    $matrix[$i][$j]{pointer} = "diagonal";
                }
                else {
                    $matrix[$i][$j]{score}   = $left_score;
                    $matrix[$i][$j]{pointer} = "left";
                }
            } else {
                if ($up_score >= $left_score) {
                    $matrix[$i][$j]{score}   = $up_score;
                    $matrix[$i][$j]{pointer} = "up";
                }
                else {
                    $matrix[$i][$j]{score}   = $left_score;
                    $matrix[$i][$j]{pointer} = "left";
                }
            }
            
            # set maximum score
            if ($matrix[$i][$j]{score} > $max_score) {
                $max_i     = $i;
                $max_j     = $j;
                $max_score = $matrix[$i][$j]{score};
            }
        }
    }
    
    # trace-back
    
    my $align1 = "";
    my $align2 = "";
    
    my $j = $max_j;
    my $i = $max_i;
    
    while (1) {
        last if $matrix[$i][$j]{pointer} eq "none";
        
        if ($matrix[$i][$j]{pointer} eq "diagonal") {
            $align1 .= substr($seq1, $j-1, 1);
            $align2 .= substr($seq2, $i-1, 1);
            $i--; $j--;
        }
        elsif ($matrix[$i][$j]{pointer} eq "left") {
            $align1 .= substr($seq1, $j-1, 1);
            $align2 .= "-";
            $j--;
        }
        elsif ($matrix[$i][$j]{pointer} eq "up") {
            $align1 .= "-";
            $align2 .= substr($seq2, $i-1, 1);
            $i--;
        }   
    }
    
    
    $align1 = reverse $align1;
    $align2 = reverse $align2;
    if ($max_score >= $ALL_maxscore)
    {   $ALL_maxscore = $max_score;
        print OUT "CRISPR:\t\t$align1\n";
        print OUT "Sequence:\t$align2\n";
        print OUT "SeqName: ";
        print OUT "Score: $max_score\n\n";
    }
}
print OUT "\n\n\n ALIGNMENT COMPLETED AT: ";
&TimeStamp;


close OUT;
# -----SUBROUTINES-----
sub ReadFasta
{   my $file = $_[0];
	$/=">";
	open(FASTA,"<$file") or die "\n\n\n Nada $file\n\n\n";
	@FILE=<FASTA>;
	close(FASTA);
	shift(@FILE); 
	foreach my $orf (@FILE)
	{	my @Lines = split(/\n/,$orf);
		my $name = $Lines[0];
		my $seq = "";
		foreach my $i (1..$#Lines)
		{	$seq .= $Lines[$i]; }
		$seq =~ s/>//;
		$NTs{$name} = $seq;
	}
	$/="\n"; # reset input break character
}
#----------
sub TimeStamp
{	print OUT strftime("%d-%b-%Y %H:%M:%S\n",localtime(time()));	}

exit 0;
