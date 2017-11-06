#!/usr/bin/perl

# MANUAL FOR orf_abundance.pl

=pod

=head1 NAME

orf_abundance.pl -- Calculate the abundance of ORF sequences from MetaGene using BAM files

=head1 SYNOPSIS

 orf_abundance.pl --fasta=/Path/to/input_orfs.fasta --bam=/Path/to/input.bam --out=/Path/to/output.txt
                     [--help] [--manual]

=head1 DESCRIPTION

 Will calculate the abundance of each input ORF by parsing the header that MetaGene Annotator
 produces and using that to look through a SORTED BAM file. Abundance is reported as coverage
 (not normalized) or as coverage per Gbp mapped to the whole BAM file (kind of normalized).
 
=head1 OPTIONS

=over 3

=item B<-f, --fasta>=FILENAME

Input file in FASTA format. (Required) 

=item B<-b, --bam>=FILENAME

Input sorted BAM file. (Required)

=item B<-o, --out>=FILENAME

Output file in tsv format. (Required) 

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
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS WITH NO DEFAULT
my($fasta,$bam,$outfile,$help,$manual);

GetOptions (	
				"f|fasta=s"	=>	\$fasta,
                                "b|bam=s"       =>      \$bam,
				"o|out=s"	=>	\$outfile,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --fasta not found.\n\n", -exitval => 2, -verbose => 1)  if (! $fasta );
pod2usage( -msg  => "\n\n ERROR!  Required argument --bam not found.\n\n", -exitval => 2, -verbose => 1)  if (! $bam );
pod2usage( -msg  => "\n\n ERROR!  Required argument --out not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile );

## Globals
my %Orf; ## Orf coordinates
my %Cov; ## Coverage for each ORF
my %Len; ## Length of each ORF
my %Name;
my @Order;
my $bases_mapped=0;

if ($fasta =~ m/\.gz$/) { ## if a gzip compressed fasta
    open(IN,"gunzip -c $fasta |") || die "\n\n Cannot open the input file: $fasta\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$fasta") || die "\n\n Cannot open the input file: $fasta\n\n";
}
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	my ($orf_name,$base,$start,$stop) = parse_header($_);
	for (my $i=$start; $i<= $stop; $i++) {
	    $Orf{$base}{$i} = $orf_name; ## Need this because when we see the contig name and base position in the BAM file we need to know what ORF it belongs to
	}
	my $len = $stop-$start+1;
	$Len{$orf_name} = $len;
	$Cov{$orf_name} = 0;
	$Name{$orf_name} = $base;
	push(@Order, $orf_name);
    }
}
close(IN);

unless (-s $bam) { die "\n Error: The BAM file your provided is either empty or not there: $bam\n" }

open(my $cmd, '-|', 'samtools', 'depth', $bam) or die $!;
while (my $line = <$cmd>) {
    my @a = split(/\t/, $line);
    if (exists $Orf{$a[0]}{$a[1]}) { $Cov{$Orf{$a[0]}{$a[1]}} += $a[2]; }
    $bases_mapped += $a[2];
}
close $cmd;
$bases_mapped /= 1000000000;

open(OUT,">$outfile") || die "\n Error: Cannot write to the file: $outfile\n";
print OUT "#" . join("\t", "orf", "length", "coverage", "norm_cov") . "\n";
foreach my $orf_name (@Order) {
    $Cov{$orf_name} = $Cov{$orf_name} / $Len{$orf_name};
    my $norm_cov = $Cov{$orf_name} / $bases_mapped;
    print OUT join("\t", $orf_name, $Len{$orf_name}, $Cov{$orf_name}, $norm_cov) . "\n";
}
close(OUT);

sub parse_header
{
    my $s = $_[0];
    $s =~ s/^>//;
    my $orf_name = $s;
    my @S = split(/_/, $s);
    pop(@S);
    my $stop = pop(@S);
    my $start = pop(@S);
    my $base = join("_", @S);
    if ($start > $stop) {
	my $tmp = $start; $start=$stop; $stop = $tmp;
    }
    return($orf_name,$base,$start,$stop);
}

exit 0;
