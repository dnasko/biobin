#!/usr/bin/perl -w

# MANUAL FOR smith_waterman.pl

=pod

=head1 NAME

smith_waterman.pl -- The Smith-Waterman algorithm for global sequence alignment

=head1 SYNOPSIS

 smith_waterman.pl --infile FILENAME --outfile FILENAME --seq SEQUENCE_STRING
                     [--help] [--manual]

=head1 DESCRIPTION

Perl script implimenting the Smith-Waterman algorithm for global seqence alignment.
Adapted from a script provided by Adam Marsh.

=head1 OPTIONS

=over 3

=item B<-i, --infile>=/Path/to/infile.fasta

Input file in FASTA format. (Required)

=item B<-o, --outfile>=/Path/to/outfile.txt

Output file in Text format. (Required)

=item B<-s, --seq>=AGTCGTCA..

String of sequences. (Required)

=item B<-l, --match>=INT

Score to award a match. Default = 1 (Optional)

=item B<-x, --mismatch>=INT

Penatly for a mismatch. Default = -1 (Optional)

=item B<-g, --gap>=INT

Penalty for openning a gap. Default = -1 (Optional)

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
## Arguments with defaults
my ($MISMATCH,$GAP) = -1;
my $ALL_maxscore = 0;
my $MATCH = 1;

GetOptions (	
				"i|infile=s"	=>	\$infile,
				"o|outfile"	=>	\$outfile,
				"s|seq"		=>	\$sequence,
				"l|match"	=>	\$MATCH,
				"x|mismatch"	=>	\$MISMATCH,
				"g|gap"		=>	\$GAP,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage(-verbose => 1)  if ($help);
pod2usage( -msg  => "\n\nERROR!  Required arguments --infile and/or --outfile and/or --seq not found.\n\nALL ARE REQUIRED\n\n", -exitval => 2, -verbose => 1)  if (! $infile && ! $outfile && ! $sequence);

my $seq1 = $sequence;

open(OUT,">>$outfile");
print OUT "Smith-Water Algorithm Analysis\nDeveloped by Temple F. Smith and Michael S. Waterman
FASTA File: $infile
Input Sequence: $seq1
Scoring Scheme:
Match = $MATCH
Mismatch = $MISMATCH
Gap = $GAP";

my ($seqio_obj,$seq_obj);

$seqio_obj = Bio::SeqIO->new(-file => "$infile", -format => "fasta" ) or die $!;
while ($seq_obj = $seqio_obj->next_seq) {
    my $seq2 = $seq_obj->seq;
    print "$seq2\n";
}

#while ($seq_obj = $seqio_obj->next_seq) {
#    my $seq2 = $seq_obj->seq;
#    my @matrix;
#    $matrix[0][0]{score}   = 0;
#    $matrix[0][0]{pointer} = "none";
#    for(my $j = 1; $j <= length($seq1); $j++) {
#        $matrix[0][$j]{score}   = 0;
#        $matrix[0][$j]{pointer} = "none";
#    }
#    for (my $i = 1; $i <= length($seq2); $i++) {
#        $matrix[$i][0]{score}   = 0;
#        $matrix[$i][0]{pointer} = "none";
#    }
#    
#    # fill
#    my $max_i     = 0;
#    my $max_j     = 0;
#    my $max_score = 0;
#    
#    for(my $i = 1; $i <= length($seq2); $i++) {
#        for(my $j = 1; $j <= length($seq1); $j++) {
#            my ($diagonal_score, $left_score, $up_score);
#            
#            # calculate match score
#            my $letter1 = substr($seq1, $j-1, 1);
#            my $letter2 = substr($seq2, $i-1, 1);       
#            if ($letter1 eq $letter2) {
#                $diagonal_score = $matrix[$i-1][$j-1]{score} + $MATCH;
#            }
#            else {
#                $diagonal_score = $matrix[$i-1][$j-1]{score} + $MISMATCH;
#            }
#            
#            # calculate gap scores
#            $up_score   = $matrix[$i-1][$j]{score} + $GAP;
#            $left_score = $matrix[$i][$j-1]{score} + $GAP;
#            
#            if ($diagonal_score <= 0 and $up_score <= 0 and $left_score <= 0) {
#                $matrix[$i][$j]{score}   = 0;
#                $matrix[$i][$j]{pointer} = "none";
#                next; # terminate this iteration of the loop
#            }
#            
#            # choose best score
#            if ($diagonal_score >= $up_score) {
#                if ($diagonal_score >= $left_score) {
#                    $matrix[$i][$j]{score}   = $diagonal_score;
#                    $matrix[$i][$j]{pointer} = "diagonal";
#                }
#                else {
#                    $matrix[$i][$j]{score}   = $left_score;
#                    $matrix[$i][$j]{pointer} = "left";
#                }
#            } else {
#                if ($up_score >= $left_score) {
#                    $matrix[$i][$j]{score}   = $up_score;
#                    $matrix[$i][$j]{pointer} = "up";
#                }
#                else {
#                    $matrix[$i][$j]{score}   = $left_score;
#                    $matrix[$i][$j]{pointer} = "left";
#                }
#            }
#            
#            # set maximum score
#            if ($matrix[$i][$j]{score} > $max_score) {
#                $max_i     = $i;
#                $max_j     = $j;
#                $max_score = $matrix[$i][$j]{score};
#            }
#        }
#    }
#    
#    ## Trace-back
#    
#    my $align1 = "";
#    my $align2 = "";
#    
#    my $j = $max_j;
#    my $i = $max_i;
#    
#    while (1) {
#        last if $matrix[$i][$j]{pointer} eq "none";
#        
#        if ($matrix[$i][$j]{pointer} eq "diagonal") {
#            $align1 .= substr($seq1, $j-1, 1);
#            $align2 .= substr($seq2, $i-1, 1);
#            $i--; $j--;
#        }
#        elsif ($matrix[$i][$j]{pointer} eq "left") {
#            $align1 .= substr($seq1, $j-1, 1);
#            $align2 .= "-";
#            $j--;
#        }
#        elsif ($matrix[$i][$j]{pointer} eq "up") {
#            $align1 .= "-";
#            $align2 .= substr($seq2, $i-1, 1);
#            $i--;
#        }   
#    }
#    
#    
#    $align1 = reverse $align1;
#    $align2 = reverse $align2;
#    if ($max_score >= $ALL_maxscore)
#    {   $ALL_maxscore = $max_score;
#        print OUT "CRISPR:\t\t$align1\n";
#        print OUT "Sequence:\t$align2\n";
#        print OUT "SeqName: ";
#        print OUT "Score: $max_score\n\n";
#    }
#}


close OUT;


exit 0;
