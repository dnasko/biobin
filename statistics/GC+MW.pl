#!/usr/bin/perl -w

# MANUAL FOR GC+MW.pl

=pod

=head1 NAME

 GC+MW.pl -- create Protein MW / ORF GC plot

=head1 SYNOPSIS

 GC+MW.pl --in=/Path/to/infile.fasta --out=output.pdf
                     [--help] [--manual]

=head1 DESCRIPTION

 Given a FASTA of NT ORFs, create a GC/MW plot
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input ORF file in NT FASTA or format. (Required) 

=item B<-o, --out>=FILENAME 

Output file in PDF format. (Required)

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
				"o|outfile=s"     =>      \$outfile,
                                "h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );
pod2usage( -msg  => "\n\n ERROR!  Required argument --outfile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile );

## Create hash of AA MW's (mass in Daltons)
my %MW = (
    A=>89.0935,  R=>174.2017, D=>133.1032, N=>132.1184,
    C=>121.1590, E=>147.1299, Q=>146.1451, G=>75.0669,
    H=>155.1552, I=>131.1736, L=>131.1736, K=>146.1882,
    M=>149.2124, F=>165.1900, P=>115.1310, S=>105.0930,
    T=>119.1197, W=>204.2262, Y=>181.1894, V=>117.1469
);
my %Codon = (
    'GCT' => 'A', 'GCC' => 'A', 'GCA' => 'A', 'GCG' => 'A', 'TTA' => 'L',
    'TTG' => 'L', 'CTT' => 'L', 'CTC' => 'L', 'CTA' => 'L', 'CTG' => 'L',
    'CGT' => 'R', 'CGC' => 'R', 'CGA' => 'R', 'CGG' => 'R', 'AGA' => 'R',
    'AGG' => 'R', 'AAA' => 'K', 'AAG' => 'K', 'AAT' => 'N', 'AAC' => 'N',
    'ATG' => 'M', 'GAT' => 'D', 'GAC' => 'D', 'TTT' => 'F', 'TTC' => 'F',
    'TGT' => 'C', 'TGC' => 'C', 'CCT' => 'P', 'CCC' => 'P', 'CCA' => 'P',
    'CCG' => 'P', 'CAA' => 'Q', 'CAG' => 'Q', 'TCT' => 'S', 'TCC' => 'S',
    'TCA' => 'S', 'TCG' => 'S', 'AGT' => 'S', 'AGC' => 'S', 'GAA' => 'E',
    'GAG' => 'E', 'ACT' => 'T', 'ACC' => 'T', 'ACA' => 'T', 'ACG' => 'T',
    'GGT' => 'G', 'GGC' => 'G', 'GGA' => 'G', 'GGG' => 'G', 'TGG' => 'W',
    'CAT' => 'H', 'CAC' => 'H', 'TAT' => 'Y', 'TAC' => 'Y', 'ATT' => 'I',
    'ATC' => 'I', 'ATA' => 'I', 'GTT' => 'V', 'GTC' => 'V', 'GTA' => 'V',
    'GTG' => 'V'
    );

my $header;
my $seq = "";

print "gc\tmw\n";
open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
while(<IN>) {
    chomp;
    unless ($header) {
	$header = $_;
	$header =~ s/^>//;
    }
    elsif ($_ =~ m/^>/) {
	my $gc      = calc_gc($seq);
	my $peptide = translate($seq);
	my $mw      = calc_mw($peptide);
	$mw /= 1000; # convert daltons to kilo-daltons
	my $normalized_mw = $mw / length($seq);
	print $gc . "\t" . $normalized_mw . "\n";
	$seq = "";
    }
    else {
	$seq = $seq . $_;
    }
}
my $gc      = calc_gc($seq);
my $peptide = translate($seq);
my $mw      = calc_mw($peptide);
$mw /= 1000; # convert daltons to kilo-daltons
my $normalized_mw = $mw/ length($seq);
print $gc . "\t" . $normalized_mw . "\n";
## Subroutines

sub calc_gc
{
    my $seq = $_[0];
    my $gc = $seq =~ tr/GCgc/GCGC/;
    my $gc_content = $gc / length($seq);
    return($gc_content);
}
sub translate
{
    my $seq = $_[0];
    my $peptide = "";
    for (my $i=0; $i <length($seq); $i += 3) {
	my $triplet = substr $seq, $i, 3;
	if (exists $Codon{$triplet}) {
	    $peptide = $peptide . $Codon{$triplet};
	}
    }
    return($peptide);
}
sub calc_mw
{
    my $peptide = $_[0];
    my @peps = split(//, $peptide);
    my $weight = 0;
    foreach my $p (@peps) {
	if (exists $MW{$p}) {
	    $weight += $MW{$p};
	}
	else {
	    die "\n Cannot get the weight for this odd ball: $p\n";
	}
    }
    return($weight);
}

exit 0;
