#!/usr/bin/perl -w

# MANUAL FOR add_tags.pl

=pod

=head1 NAME

add_tags.pl -- add the QIIME tags to deconvoluted samples

=head1 SYNOPSIS

 add_tags.pl -in /Path/to/direcotory/containing/infiles/ -out /Path/to/outfile.fasta
                     [--help] [--manual]

=head1 DESCRIPTION

 Will apply tags to the FASTA header for QIIME to understand what the samples are.
 Need to point the script to a directory containing ONLY N number of FASTA files each
 representing a deconvoluted sample. Each file needs to be named in this convention: 
 "barcode.fasta" so an example where the barcode is 2D01 the FASTA file will look like:
 "2D01.fasta" If this is the first of 12 other barcodes, then there ought to be 12 other
 FASTA files in that directory.
 
=head1 OPTIONS

=over 3

=item B<-i, --indir>=FILENAME

Input directory containing FASTA files. (Required) 

=item B<-o, --out>=FILENAME

Output file in FASTA format. (Optional) Default = STDOUT

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
my($indir,$outfile,$help,$manual);

GetOptions (	
				"i|indir=s"	=>	\$indir,
				"o|outfile=s"	=>	\$outfile,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument -indir not found.\n\n", -exitval => 2, -verbose => 1)  if (! $indir );

my $counter = 1;
my @Files = `/bin/ls $indir`;

if (! $outfile) {
    foreach my $file (@Files) {
	chomp($file);
	my $tag = $file;
	$tag =~ s/.fasta//;
	open(IN,"<$file") || die "\n\n Cannot open the input file: $file\n\n";
	while(<IN>) {
	    chomp;
	    if ($_ =~ m/^>/) {
		my $string = $_;
		$string =~ s/^>/>$tag\_$counter /;
		print "$string\n";
		$counter++;
	    }
	    else {
		print "$_\n";
	    }
	}
	close(IN);
    }
}
else { ## IF YOU USED THE -o FLAG, essentially everything is repeated here.
    open(OUT,">$outfile") || die "\n\n Cannot open the outfile: $outfile\n\n";
    foreach my $file (@Files) {
        chomp($file);
        my $tag = $file;
	$tag =~ s/.fasta//;
        open(IN,"<$file") || die "\n\n Cannot open the input file: $file\n\n";
	while(<IN>) {
            chomp;
            if ($_ =~ m/^>/) {
		my $string = $_;
		$string =~ s/^>/>$tag\_$counter /;
		print OUT "$string\n";
                $counter++;
            }
            else {
                print OUT "$_\n";
            }
        }
        close(IN);
    }
    close(OUT);
}

exit 0;
