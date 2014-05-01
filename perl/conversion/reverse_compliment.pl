#!/usr/bin/perl -w

# MANUAL FOR reverse_compliment.pl

=pod

=head1 NAME

reverse_compliment.pl -- reverse compliments sequences

=head1 SYNOPSIS

 reverse_compliment.pl -in /Path/to/infile.fasta -out /Path/to/output.fasta
                     [--help] [--manual]

=head1 DESCRIPTION

 Takes in a FASTA file of sequences and spits out a FASTA of the sequences in reverse compliment form.
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in FASTA format. (Required) 

=item B<-o, --out>=FILENAME

Output file in FASTA format. (Required) 

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
pod2usage( -msg  => "\n\n ERROR!  Required argument -outfile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile);

my $line_count = 0;
my $seq;
open(OUT,">$outfile") || die "\n\n Error: Cannot open the outfile: $outfile\n\n";
if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}
while(<IN>) {
    chomp;
    if ($line_count == 0) {
	print OUT $_ . "\n";
    }
    else {
	if ($_ =~ m/^>/) {
	    my $rev = scalar reverse $seq;
	    $rev =~ tr/ATGCatgc/TACGTACG/;
	    print OUT $rev . "\n" . $_ . "\n";
	    $seq = "";
	}
	else {
	    $seq = $seq . $_;
	}
    }
    $line_count++;
}
close(IN);

my $rev = scalar reverse $seq;
$rev =~ tr/ATGCatgc/TACGTACG/;
print OUT $rev ."\n";

close(OUT);

exit 0;
