#!/usr/bin/perl -w

# MANUAL FOR fasta2phylip.pl

=pod

=head1 NAME

fasta2phylip.pl -- convert sequence alignment in FASTA format to PHYLIP format

=head1 SYNOPSIS

 fasta2phylip.pl -in /Path/to/infile.fasta -out /Path/to/output.phy
                     [--help] [--manual]

=head1 DESCRIPTION

 Converts FASTA MSA to PHYLIP MSA (sequential format).
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in FASTA format. (Required) 

=item B<-o, --out>=FILENAME

Output file in PHYLIP format. (Required) 

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

if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}

## First run through for sequence count and length determination.
my $total_seqs = 0;
my $length = 0;
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	$total_seqs++;
    }
    else {
	$length = length($_);
    }
}
close(IN);
## Second run through
my $counter = 0;

open(OUT,">$outfile") || die "\n\n Cannot write to outfile: $outfile\n\n";
if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}
print OUT "$total_seqs\t$length\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	my $header = $_;
	$header =~ s/^>//;
	$header =~ s/-/_/g;
	$header =~ s/\.//g;
	if (length($header) > 10) {
	    print STDERR "$header -> this header exceeds 10 characters. New (smaller) name: ";
	    $header = <STDIN>;
	    chomp($header);
	}
	print OUT "$header";
	my $make_up = 12 - length($header);
	for(my $i = 0; $i < $make_up; $i++) {
	    print OUT " ";
	}
	$counter++;
    }
    else {
	print OUT "$_\n";
    }
}
close(IN);
close(OUT);

exit 0;
