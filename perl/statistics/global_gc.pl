#!/usr/bin/perl -w
use strict;

my $infile = $ARGV[0];
my ($bases,$gcs) = (0,0);

open(IN,"<$infile") || die "\n Cannot open the file: $infile\n";
while(<IN>) {
    chomp;
    unless ($_ =~ m/^>/) {
	$bases += length($_);
	my $seq = $_;
	$gcs += $seq =~ tr/GCgc/GCGC/;
    }
}	    
close(IN);

my $gc_content = $gcs / $bases;
print $gc_content . "\n";

exit 0;

