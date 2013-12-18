#!/usr/bin/perl

#MANUAL FOR fastq2fasta.pl

=pod

=head1 NAME

fastq2fasta.pl -- converts a FASTQ file to a FASTA file

=head1 SYNOPSIS

 fastq2fasta.pl -in /Path/to/infile.fastq -out /Path/to/outfile.fasta
                         [-help]  [-manual]

=head1 DESCRIPTION

 Converts a FASTQ file to a FASTA file. Note that this program does not
 create a .qual file. If you need a qual file, see fastq2fasta_qual.pl

=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in FASTQ format. (Required)

=item B<-o, --out>=FILENAME

Output file in FASTA format. (Optional)
 default prints to STDOUT.

=item B<-h, --help>

Displays the usage message. (Optional)

=item B<-m, --manual>

Displays fill manual. (Optional)

=back

=head1 DEPENDENCIES

Requires the following Perl libraries.

-none-

=head1 AUTHOR

Written by Daniel Nasko,
Center for Bioinformatics and Computational Biology, University of Delaware.

=head1 REPORTING BUGS

Report bugs to dnasko@udel.edu

=head1 COPYRIGHT

Copyright 2013 Daniel Nasko.
License GPLv3+: GPU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRENTY, to the extent permitted by law.

Please acknowledge author and affliliation in published work arising from thie script's
usage <http://bioinformatics.udel.edu/Core/Acknowledge>.

=cut

use strict;
use Getopt::Long;
use File::Basename;
use Pod::Usage;

## ARGUMENTS WITH DEFAULTS
my $outfile;

## ARGUMENTS WITH NO DEFAULT
my($infile,$help,$manual);

GetOptions (
                       "i|in=s"       =>     \$infile,
                       "o|out=s"      =>     \$outfile,
                       "h|help=s"     =>     \$help,
                       "m|manual=s"   =>     \$manual);

## VALIDATE ARGS
pod2usage(-verbose => 2) if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} ) if ($help);
pod2usage( -msg  => "\n\n Fatal! Required argument -in not found.\n\n", -exitval => 2, -verbose => 1) if (! $infile );

my $line_count = 0;

open(IN,"<$infile") || die "\n\n Error! Cannot open the input file: $infile\n\n";
if ($outfile eq "") {
    while(<IN>) {
	chomp;
	if ($line_count == 0) {
	    unless ($_ =~ m/^@/) {
		die "\n\n Error: The infile you have provided does not appear to be in FASTQ format, note the header line:\n\n$_\n\n";
	    }
	    my $header = $_;
	    $header =~ s/^@/>/;
	    print "$header\n";
	}
	elsif ($line_count == 1) {
	    print $_ . "\n";
	}
	$line_count++;
	if ($line_count == 4) {
	    $line_count = 0;
	}
    }
}
else {
    open(OUT,">$outfile") || die "\n\n Error! Cannot open the output file: $outfile\n\n";
    while(<IN>) {
        chomp;
        if ($line_count == 0) {
            unless ($_ =~ m/^@/) {
                die "\n\n Error: The infile you have provided does not appear to be in FASTQ format, note the header line:\n\n$_\n\n";
            }
            my $header = $_;
            $header =~ s/^@/>/;
            print OUT "$header\n";
        }
        elsif ($line_count == 1) {
            print OUT $_ . "\n";
        }
	$line_count++;
        if ($line_count == 4) {
            $line_count= 0;
        }
    }
    close(OUT);
}
close(IN);

exit 0;
