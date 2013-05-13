#!/usr/bin/perl -w

# MANUAL FOR NeedlemanWunschAlignment.pl

=pod

=head1 NAME

NeedlemanWunschAlignment.pl -- Perform NW on two input sequences

=head1 SYNOPSIS

 NeedlemanWunschAlignment.pl --fasta /path/to/file.fasta
                     [--help] [--manual]

=head1 DESCRIPTION

 Takes in a FASTA file contianing no more and no less than two sequences
 and performs a Needleman Wunsch global alignment.
 
=head1 OPTIONS

=over 3

=item B<-f, --fasta>=FILENAME

Input file in FASTA format. (Required) 

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries.



=head1 AUTHOR

Written by Daniel Nasko, 
Center for Bioinformatics and Computational Biology, University of Delaware.

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
use POSIX;
use LWP::Simple;
$|=1;               ## Forces print output to be sent to screen realtime

#ARGUMENTS WITH NO DEFAULT
my($fasta,$help,$manual);

GetOptions (	
				"f|fasta=s"	=>	\$fasta,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required arguments --fasta not found.\n\n", -exitval => 2, -verbose => 1)  if (! $fasta );
my $num_seqs = `fgrep -c ">" $fasta`;
unless ($num_seqs == 2) {    die "\n\n Your input FASTA file contained $num_seqs\n needs to contain only 2 !!!\n";}

##=== ALIGNMENT PARAMETERS ===##
my $match = 1;                ## Match bonus
my $gap = -3;                 ## Gap penalty
my $mismatch = -1;            ## Mismatch penalty
my @M;                        ## Alignment matrix, filled by similarity scores
##============================##

## Read in the FASTA File
print "\n\n Beginning Your Needleman Wunsch Alignment . . . \n\n";
open(IN,"<$fasta") || die "\n\n cannot open the fasta file $fasta\n\n";
$/='>';
my @FASTA = <IN>;
close(IN);
shift(@FASTA);
my @seq1 = split(/\n/, $FASTA[0]);
my @seq2 = split(/\n/, $FASTA[1]);
my $seq_1_header = $seq1[0];
my $seq_2_header = $seq2[0];
my ($seq_1,$seq_2);
foreach my $i (1..$#seq1) { $seq_1 .= $seq1[$i]; }
$seq_1 =~ s/>//;
foreach my $i (1..$#seq2) { $seq_2 .= $seq2[$i]; }
$/="\n";

## Iteratively execute the similarilty scoring subroutine
my $max = -99999;
my $score = &Similarity($seq_1,$seq_2);
if ($score > $max) {
    $max = $score;
    print "\n\n---------------------------------\n";
    print "\tAlignment: $seq_2_header\n\tScore = $score\n";
    foreach my $i (&Alignment($seq_1,$seq_2)) {
        print "\t\t\t", $i, "\n";
    }
}
else {
    print ".";
}

print "\n\n\tProcess Complete . . . \n\n";

##===================##
##=== Subroutines ===##
##===================##
sub Similarity
{
    my ($s,$t) = @_;    ## Sequences to be aligned
    foreach my $i (0..length($s)) { $M[$i][0] = $gap * $i; }
    foreach my $j (0..length($t)) { $M[0][$j] = $gap * $j; }
    foreach my $i (1..length($s)) {
        foreach my $j (1..length($t)) {
            my $p = &ID(substr($s,$i-1,1),substr($t,$j-1,1));
            $M[$i][$j] = &MAX($M[$i-1][$j] + $gap, $M[$i][$j-1] + $gap, $M[$i-1][$j-1] + $p);
        }
    }
    return ( $M[length($s)][length($t)] );
}
## = = = = = = = = = ##
sub ID
{
    my ($aa1,$aa2) = @_;
    return ($aa1 eq $aa2)?$match:$mismatch;
}
