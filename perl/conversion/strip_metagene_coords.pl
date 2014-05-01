#!/usr/bin/perl -w

# MANUAL FOR strip_metagene_coords.pl

=pod

=head1 NAME

strip_metagene_coords.pl -- strips the coordinates from a MetaGene FASTA file

=head1 SYNOPSIS

 strip_metagene_coords.pl -in /Path/to/infile.fasta -out /Path/to/output.fasta
                     [--help] [--manual]

=head1 DESCRIPTION

 Strips the last three coordinates from the MetaGene FASTA files, such as:
 >CFX_164FHGSA7938_89_567_1 the _89_567_1 bit will be stripped.
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in FASTA format. (Required) 

=item B<-o, --out>=FILENAME

Output file in FASTA format. Default to STDOUT (Optional)

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
use FindBin;
use Cwd 'abs_path';
use lib abs_path("$FindBin::Bin/../..");
use DNAsko::MetaGene;

#ARGUMENTS WITH NO DEFAULT
my($infile,$outfile,$help,$manual);

GetOptions (	
				"i|in=s"	=>	\$infile,
				"o|out=s"	=>	\$outfile,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument -infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );

if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile 
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else {
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}

if (! $outfile) {
    while(<IN>) {
	chomp;
	if ($_ =~ m/^>/) {
	    my $header = MetaGene::strip_coords($_);
	    print "$header\n";
	}
	else {
	    print "$_\n";
	}
    }
    close(IN);
}
else {
    open(OUT,">$outfile") || die "\n\n Cannot open the output file $outfile\n\n";
    while(<IN>) {
	chomp;
	if ($_ =~ m/^>/) {
	    my $header = MetaGene::strip_coords($_);
	    print OUT "$header\n";
	}
	else {
	    print OUT "$_\n";
	}
    }
    close(OUT);
    close(IN);
}

exit 0;
