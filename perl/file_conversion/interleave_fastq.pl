#!/usr/bin/perl -w

# MANUAL FOR interleave_fastq.pl

=pod

=head1 NAME

interleave_fastq.pl -- Takes in two FASTQ files and interleaves them together

=head1 SYNOPSIS

 interleave_fastq.pl -1 /Path/to/pair.1.fastq -2 /Path/to/pair.2.fastq -out /Path/to/output.fastq
                     [--help] [--manual]

=head1 DESCRIPTION

 Takes in two FASTQ pairs from Illumina and will interleave them into one FASTQ file.
 
=head1 OPTIONS

=over 3

=item B<-1, --one>=FILENAME

Input file (pair 1) in FASTQ format. (Required) 

=item B<-2, --two>=FILENAME

Input file (pair 2) in FASTQ format. (Required)

=item B<-o, --out>=FILENAME

Output file in FASTQ format. (Required) 

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
my($one,$two,$outfile,$help,$manual);

GetOptions (	
				"1|one=s"	=>	\$one,
				"2|two=s"       =>      \$two,
                                "o|out=s"	=>	\$outfile,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument -one not found.\n\n", -exitval => 2, -verbose => 1)  if (! $one );
pod2usage( -msg  => "\n\n ERROR!  Required argument -two not found.\n\n", -exitval => 2, -verbose => 1)  if (! $two );
pod2usage( -msg  => "\n\n ERROR!  Required argument -out not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile);

my %Header;
my %Sequence;
my %Quality; 

if ($one =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $one |") || die "\n\n Cannot open the input file: $one\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$one") || die "\n\n Cannot open the input file: $one\n\n";
}

my $l = 0;
my $counter = 1;
while(<IN>) {
    chomp;
    if ($l == 0) {
	$Header{$counter} = $_;
    }
    elsif ($l == 1) {
	$Sequence{$counter} = $_;
    }
    elsif ($l == 3) {
	$l = -1;
	$Quality{$counter} = $_;
	$counter++;
    }
    $l++;
}
close(IN);

$counter = 1;
$l = 0;

open(OUT,">$outfile") || die "\n\n Cannot open the outfile: $outfile\n\n";
if ($two =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $two |") || die "\n\n Cannot open the input file: $two\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$two") || die "\n\n Cannot open the input file: $two\n\n";
}
while(<IN>) {
    chomp;
    if ($l == 0) {
	if (exists $Header{$counter}) {
	    print OUT "$Header{$counter}\n$Sequence{$counter}\n+\n$Quality{$counter}\n";
	}
	else {
	    die "\n\n Oh no, you have a mismatch: $counter\n\n";
	}
	print OUT "$_\n";
    }
    elsif ($l == 1) {
	print OUT "$_\n";
    }
    elsif ($l == 3) {
	$l = -1;
	print OUT "$_\n";
	$counter++;
    }
    $l++;
}
close(IN);
close(OUT);

exit 0;
