#!/usr/bin/perl -w

# MANUAL FOR fasta2phylip.pl

=pod

=head1 NAME

strip_fasta_ids.pl -- strips fasta IDs and will print tha mapping file

=head1 SYNOPSIS

 strip_fasta_ids.pl -in /Path/to/infile.fasta -out /Path/to/output.fasta
                     [--help] [--manual]

=head1 DESCRIPTION

 Strips headers off FASTA file and prints the old IDs into a mapping file
 
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

my $r = scalar reverse $outfile;
$r =~ s/^.*?\.//;
my $mapping = scalar reverse $r;
$mapping = $mapping . ".map";
my $counter = 0;

my $num_seqs = `egrep -c "^>" $infile`;
chomp($num_seqs);

open(OUTF,">$outfile") || die "\n\n Can't write to output fasta: $outfile\n\n";
open(OUTM,">$mapping") || die "\n\n Can't open the mapping file: $mapping\n\n";
if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	$counter++;
	my $number;
	my $diff = length($num_seqs) - length($counter);
	for (my $i=0;$i < $diff;$i++) {
	    $number = $number . "0";
	}
	$number = $number . $counter;
	my $header = $_;
	$header =~ s/^>//;
	print OUTF ">" . $number . "\n";
	print OUTM "$number\t$header\n";
    }
    else {
	print OUTF "$_\n";
    }
}
close(IN);
close(OUTM);
close(OUTF);

exit 0;
