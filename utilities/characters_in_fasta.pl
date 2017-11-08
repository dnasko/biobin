#!/usr/bin/perl

# MANUAL FOR characters_in_fasta.pl

=pod

=head1 NAME

characters_in_fasta.pl -- count and report what characters are in the FASTA file, not the header

=head1 SYNOPSIS

 characters_in_fasta.pl --fasta=/Path/to/infile.fasta
                     [--help] [--manual]

=head1 DESCRIPTION

 Will count the characters in the sequences of a FASTA file.
 
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
Center for Bioinformatics and Computational Biology, University of Maryland.

=head1 REPORTING BUGS

Report bugs to dnasko@umiacs.umd.edu

=head1 COPYRIGHT

Copyright 2017 Daniel Nasko.  
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  

=cut


use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS WITH NO DEFAULT
my($fasta,$help,$manual);

GetOptions (	
				"f|fasta=s"     => \$fasta,
                                "h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --fasta not found.\n\n", -exitval => 2, -verbose => 1)  if (! $fasta );

my %Hash;

if ($fasta =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $fasta |") || die "\n\n Cannot open the input file: $fasta\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$fasta") || die "\n\n Cannot open the input file: $fasta\n\n";
}
while(<IN>) {
    $_ =~ s/\r[\n]*/\n/gm;
    chomp;
    unless ($_ =~ m/^>/) {
	my @a = split(//, $_);
	foreach my $i (@a) { $Hash{$i}++; }
    }
}
close(IN);

foreach my $i (sort keys %Hash) {
    print $i . "\t" . $Hash{$i} . "\n";
}

exit 0;
