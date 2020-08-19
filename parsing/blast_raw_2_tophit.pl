#!/usr/bin/perl -w
use strict;

my $infile = $ARGV[0];

my $query_id;
my $tophit;
my $check_flag = 0;
my $grab_flag = 0;

open(IN,"<$infile") || die "\n Cannot open the file: $infile\n";
while(<IN>) {
    chomp;
    my $line = $_;
    if ($line =~ m/^Query= /) {
	$tophit = "";
	$query_id = $line;
	$query_id =~ s/^Query= //;
	$query_id =~ s/ .*//;
	$check_flag = 1;
    }
    elsif ($check_flag == 1 && $line =~ m/^ Score = /) {
	$check_flag = 0;
	$grab_flag = 0;
	print join("\t", $query_id, $tophit) . "\n";
    }
    elsif ($check_flag == 1 && $line =~ m/^>/) {
	$tophit = $line;
	$tophit =~ s/^>//;
	$grab_flag = 1;
	# print $tophit . "\n";
    }
    elsif ($grab_flag == 1 && $line !~ m/^Length=\d+/) {
	$tophit = $tophit . $line;
    }
    
}
close(IN);

exit 0;
