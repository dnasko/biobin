#!/usr/bin/perl
use strict;

my $infile = $ARGV[0];

open(IN,"<$infile");
while(<IN>) {
	chomp;
	my $line = $_;
	if ($line =~ m/>/) {
		print "\n$line\n";
	}
	else {
		print "$line";
	}
}
close(IN);
