#!/usr/bin/perl -w
use strict;

my $infile = $ARGV[0];

open(IN,"<$infile") || die "\n Cannot open the file: $infile\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	print $_ . "\n";
    }
}
close(IN);

exit 0;
