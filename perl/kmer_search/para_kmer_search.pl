#!/usr/bin/perl -w

# MANUAL FOR kmer_search.pl

=pod

=head1 NAME

kmer_search.pl -- search for 12-mer matches in your FASTA against a DB

=head1 SYNOPSIS

 kmer_search.pl --in=/Path/to/peptides.fasta --db=/Path/to/peptides_db --outdir=/Path/to/outdir/
                     [--help] [--manual]

=head1 DESCRIPTION

 Will compare all of the peptide 12-mers in your FASTA against a database
 of 12-mers. All matches and pertinent information are printed in --out.
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in peptide FASTA format. (Required) 

=item B<-d, --db>=FILENAME

12-mer database. (Required)

=item B<-o, --outdir>=FILENAME

Output directory. (Required) 

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries.

Redis

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
use Scalar::Util qw(looks_like_number);
use threads;

#ARGUMENTS WITH NO DEFAULT
my($infile,$db,$outdir,$help,$manual);

GetOptions (	
				"i|in=s"	=>	\$infile,
				"o|outdir=s"	=>	\$outdir,
                                "d|db=s"        =>      \$db,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );
pod2usage( -msg  => "\n\n ERROR!  Required argument --outdir not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outdir );
pod2usage( -msg  => "\n\n ERROR!  Required argument --db not found.\n\n", -exitval => 2, -verbose => 1)  if (! $db );

my $header;
my ( %Kmers,%Results,%Id,%PerSeq );
my $total_mers = 0;
my $kmers_match = 0;

if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	$header = $_;
	$header =~ s/^>//;
	$header =~ s/ .*//;
    }
    else {
	for (my $i=0; $i<=length($_)-12; $i++) {
	    my $mer = substr $_, $i, 12;
	    $Kmers{$mer}++;
	    if (exists $Id{$mer}) {
		$Id{$mer} = $Id{$mer} . "," . $header;
	    }
	    else {
		$Id{$mer} = $header;
	    }
	    $total_mers++;
	}
    }
}
close(IN);


open(IN,"<$db") || die "\n\n Cannot open the input file: $db\n\n";
while(<IN>) {
    chomp;
    my @Fields = split(/\t/, $_);
    if (exists $Kmers{$Fields[0]}) { ## If there's a DB hit
	my @libs = split(/,/, $Fields[2]);
	my @seqs = split(/,/, $Id{$Fields[0]});
	foreach my $lib (@libs) {
	    $Results{$lib} += (1/scalar(@libs)) * $Kmers{$Fields[0]}; ## multiply
	    foreach my $seq (@seqs) {
		$PerSeq{$seq}{$lib}++;
	    }
	}
	$kmers_match += $Kmers{$Fields[0]};
	$Kmers{$Fields[0]} = $Fields[2];
    }
}
close(IN);

open(OUT,">$outdir/library_counts.txt") || die "\n Cannot open the file: $outdir/library_counts.txt\n";
foreach my $lib (sort { $Results{$b} <=> $Results{$a} } keys %Results) {
    print OUT $lib . "\t" . $Results{$lib} . "\n";
}  
close(OUT);

open(OUT,">$outdir/gen_summary.txt") || die "\n Cannot open the file: $outdir/gen_summary.txt\n";
my $percent = $kmers_match / $total_mers;
$percent *= 100;
print OUT " Total k-mers in query file = $total_mers\n";
print OUT " k-mers with a match = $kmers_match ( $percent % )\n";
close(OUT);

open(OUT,">$outdir/per_seq_breakdown.txt") || die "\n Cannot open the file: $outdir/per_seq_breakdown.txt\n";
foreach my $sequence (keys %PerSeq) {
    foreach my $library (sort { $PerSeq{$sequence}{$b} <=> $PerSeq{$sequence}{$a} } keys %{ $PerSeq{$sequence} }) {
	print OUT $sequence . "\t" . $library . "\t" . $PerSeq{$sequence}{$library} . "\n";
    }
}
close(OUT);

exit 0;
