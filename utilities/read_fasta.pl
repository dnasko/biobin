#!/usr/bin/perl -w

# MANUAL FOR read_fasta.pl

=pod

=head1 NAME

read_fasta.pl -- Read a FASTA file, one seq at a time

=head1 SYNOPSIS

 read_fasta.pl -i /Path/to/infile.fasta -o /Path/to/output.fasta
                     [--help] [--manual]

=head1 DESCRIPTION

 Read a FASTA file
 
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

Copyright 2017 Daniel Nasko.  
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

open(OUT,">$outfile") || die "\n Cannot open the output file: $outfile\n";
if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}
my ($header,$seq);
my $line = 0;
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	if ($line>0) { # If this isn't the first header
	    print OUT ">" . $header . "\n";
	    print OUT $seq . "\n";
	    $seq = "";
	}
	$header = $_;
	$header =~ s/^>//;
    }
    else {
	$seq = $seq . $_;
    }
    $line++;
}    
close(IN);
print OUT ">" . $header . "\n";  ## LAST SEQUENCE
print OUT $seq . "\n";           ## LAST SEQUENCE

close(OUT);


exit 0;
