#!/usr/bin/perl -w

# MANUAL FOR sequence_positions.pl

=pod

=head1 NAME

sequence_positions.pl -- tells you the position(s) of a sequence

=head1 SYNOPSIS

 sequence_positions.pl -in /Path/to/infile.fasta -seq ATGCGATCGA -identity 90
                     [--help] [--manual]

=head1 DESCRIPTION

 Runs through a FASTA file and counts the positions a given sequence starts.
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in FASTA format. (Required) 

=item B<-s, --seq>=FILENAME

Sequence of interest. (Required)

=item B<-c, --identity>=INT

Percent identity to check. (Optional)
 Default = 100

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

Copyright 2014 Daniel Nasko.  
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
use String::Approx 'amatch';

#ARGUMENTS WITH NO DEFAULT
my($infile,$seq,$help,$manual);

## ARGUMENTS WITH DEFAULTS
my $identity = 100;

GetOptions (	
				"i|in=s"	=>	\$infile,
				"s|seq=s"	=>	\$seq,
				"c|identity=i"  =>      \$identity,
                                "h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument -infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );
pod2usage( -msg  => "\n\n ERROR!  Required argument -seq not found.\n\n", -exitval => 2, -verbose => 1)  if (! $seq);
my $identity_string = $identity;
$identity_string = 100 - $identity_string;
$identity_string = $identity_string . "%";
my $num_match = 0;

if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}
my %Pos;
my $sequence = "";
my $seqs = 0;
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	unless ($seqs == 0) {
	    my $target_len = length($sequence) - length($seq);
	    for (my $i=0;$i <= $target_len; $i++) {
		my $test = substr $sequence, $i, length($seq);
		if ( amatch ($seq,[ $identity_string ], $test )) {
		    my $j = $i + 1;
		    $Pos{$j}++;
		    $num_match++;
		}
	    }
	    $sequence = "";
	}
    }
    else {
	$sequence = $sequence . $_;
    }
    $seqs++;
}
close(IN);

my $sum = 0;
foreach my $i (sort {$a<=>$b} keys %Pos) {
    my $diff = $num_match - $sum;
    print "$i\t$Pos{$i}\t$diff\n";
    $sum += $Pos{$i};
}

print "\n\n Number of matches = $num_match\n\n";

exit 0;
