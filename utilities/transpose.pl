#!/usr/bin/perl -w
use strict;

my $infile = $ARGV[0];
my @Matrix;

my $i=0;
my $jmax=0;
open(IN,"<$infile") || die "\n Cannot open the file: $infile\n";
while(<IN>) {
    chomp;
    my @a = split(/\t/, $_);
    if (scalar(@a) > $jmax) { $jmax = scalar(@a); }
    for (my $j=0; $j<scalar(@a); $j++) {
	$Matrix[$i][$j] = $a[$j];
    }
    $i++;
}
close(IN);

for (my $J=0; $J<$jmax; $J++) {
    my @b;
    for (my $I=0; $I<$i; $I++) {
	push(@b, $Matrix[$I][$J]);
    }
    print join("\t", @b) . "\n";
}

exit 0;
