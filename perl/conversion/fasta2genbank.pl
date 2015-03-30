#!/usr/bin/perl -w

# MANUAL FOR fasta2genbank.pl

=pod

=head1 NAME

fasta2genbank.pl -- short descrip

=head1 SYNOPSIS

 fasta2genbank.pl --fasta=/Path/to/infile.fasta [--orfs=/Path/to/mga_orfs.aa.fasta] --out=/Path/to/output.gb
                     [--help] [--manual]

=head1 DESCRIPTION

 This is a skeleton Perl script, meant only to aid you as a template.
 
=head1 OPTIONS

=over 3

=item B<-f, --fasta>=FILENAME

Input file in FASTA format. (Required) 

=item B<-r, --orfs>=FILENAME

Input ORF FASTA file from MetaGene. (Optional)

=item B<-o, --out>=FILENAME

Output file in GenBank format. (Required) 

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
my($fasta,$orfs,$outfile,$help,$manual);

GetOptions (	
				"f|fasta=s"	=>	\$fasta,
				"r|orfs=s"      =>      \$orfs,
                                "o|out=s"	=>	\$outfile,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --fasta not found.\n\n", -exitval => 2, -verbose => 1)  if (! $fasta );
pod2usage( -msg  => "\n\n ERROR!  Required argument --outfile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile);

my $n_seqs = `egrep -c "^>" $fasta`;
chomp($n_seqs);
unless($n_seqs == 1) { die "\n should only be one sequence in that fasta file...\n"; }

## What time is it?
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time); $year += 1900;
my @abbr = qw(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC);
my $date_form = $mday . "-" . $abbr[$mon] . "-" . $year;

my ($header,$seq);
open(IN,"<$fasta") || die "\n\n Cannot open the input file: $fasta\n\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	$header = $_;
	$header =~ s/^>//;
    }
    else {
	$seq = $seq . $_;
    }
}
close(IN);

open(OUT,">$outfile") || die "\n Cannot open the file: $outfile\n";
print OUT qq|LOCUS\t$header\t| . length($seq) . qq| bp\tDNA\tlinear\tUNC\t$date_form\n|;
print OUT qq|ORIGIN\n|;
print OUT qq|FEATURES             Location/Qualifiers\n|;
print OUT qq|     source          1..| . length($seq) . "\n";

my %Orfs = read_orfs();

my @Seq = split(//, $seq);
for(my $i=0; $i<length($seq); $i++) {
    if ($i == 0) {
	for(my $j=0; $j<length(length($seq))-length($i)+3; $j++) { print OUT " "; }
	print OUT $i+1 . "  ";
    }
    if (($i % 10) == 0 && $i != 0) { print OUT " "; }
    if (($i % 60) == 0 && $i != 0) {
	print OUT "\n";
	for(my $j=0; $j<length(length($seq))-length($i)+3; $j++) { print OUT " "; }
	print OUT $i+1 . "  ";
    }
    print OUT lc($Seq[$i]);
}
print OUT "\n//";
close(OUT);

sub read_orfs
{
    my %hash;
    open(IN,"<$orfs") || die "\n Cannot open the file: $orfs\n";
    my $h;
    my $s = "";
    while(<IN>) {
	chomp;
	if ($h) {
	    
	}
	else {
	    
	}
    }
    close(IN);
}

exit 0;
