#!/usr/bin/perl -w

# MANUAL FOR kmer_search.pl

=pod

=head1 NAME

kmer_search.pl -- search for 12-mer matches in your FASTA against a DB

=head1 SYNOPSIS

 kmer_search.pl --in=/Path/to/peptides.fasta --db=/Path/to/peptides_db --out=/Path/to/output.txt
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

=item B<-o, --out>=FILENAME

Output file in tabular format. (Required) 

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
use Redis;

#ARGUMENTS WITH NO DEFAULT
my($infile,$db,$outfile,$help,$manual);

GetOptions (	
				"i|in=s"	=>	\$infile,
				"o|out=s"	=>	\$outfile,
                                "d|db=s"        =>      \$db,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );
pod2usage( -msg  => "\n\n ERROR!  Required argument --outfile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile);
pod2usage( -msg  => "\n\n ERROR!  Required argument --db not found.\n\n", -exitval => 2, -verbose => 1)  if (! $db );

my $header;
my $redis = Redis->new;

open(OUT,">$outfile") || die "\n Cannot open the file: $outfile\n";
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
	my %prefix;
	my $mers = 0;
	my $hits = 0;
	for (my $i=0; $i<=length($_)-12; $i++) {
	    my $mer = substr $_, $i, 12;
	    if (defined $redis->get($mer)) {
		my @a = split(/,/, $redis->get($mer));
		foreach my $j (@a) { $prefix{$j} += 1/scalar(@a); };
		$hits++;
	    }
	    $mers++;
	}
	my $percent = $hits / $mers;
	print OUT $header . "\t" . $hits . "\t" . $mers . "\t" . $percent . "\n";
	foreach my $j (sort { $prefix{$b} <=> $prefix{$a} } keys %prefix) {
	    print OUT "\t" . $j . "\t" . $prefix{$j} . "\n";
	}
    }
}
close(IN);
close(OUT);

exit 0;
