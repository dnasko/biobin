#!/usr/bin/perl -w
use strict;
use Statistics::R;

my $infile = $ARGV[0];

unless (scalar(@ARGV) == 1) { die "\n Usage: btab2uclust.pl /Path/to/input.btab > output.uc\n\n\n"; }

my %cluster;
my %id;
my $c=1;
my $tmp_file = "./tmp_network";
my %CLUSTERS;

open(OUT,">$tmp_file") || die "\n Cannot open the file: $tmp_file\n";
open(IN,"<$infile") || die "\n Cannot open the file: $infile\n";
while(<IN>) {
    chomp;
    my @a = split(/\t/, $_);
    unless (exists $cluster{$a[0]}) {
    	$cluster{$a[0]} = $c;
	$id{$c} = $a[0];
	$c++;
    }
    unless (exists $cluster{$a[1]}) {
    	$cluster{$a[1]} = $c;
	$id{$c}= $a[1];
    	$c++;
    }
    print OUT $cluster{$a[0]} . "\n" . $cluster{$a[1]} . "\n";
}        
close(IN);
close(OUT);

my $R = Statistics::R->new() ;
$R->startR ;
$R->send(qq`require(igraph)`);
$R->send(qq`data <- read.table("$tmp_file")`);
$R->send(qq`data <- data[,1]`);
$R->send(qq`data.g <- graph(data, directed=FALSE)`);
$R->send(qq`write(clusters(data.g)\$membership, file="./r_out")`);
$R->stopR() ;

$c=1;
open(IN,"<./r_out") || die "\n Error: Cannot open the file: ./r_out\n";
while(<IN>) {
    chomp;
    my @a = split(/ /, $_);
    foreach my $i (@a) {
	if (exists $id{$c}) {
	    # print $id{$c} . "\t" . $c . "\t" . $i . "\n";
	    push(@{$CLUSTERS{$i}}, $id{$c});
	}
	else {
	    die "\n Cannot find $c in hash ID\n";
	}
	$c++;
    }
}
close(IN);

foreach my $clstr (sort {$a<=> $b} keys %CLUSTERS) {
    print $clstr;
    foreach my $id ( @{$CLUSTERS{$clstr}} ) {
	print "\t" . $id;
    }
    print "\n";
}

print `rm $tmp_file`;
print `rm ./r_out`;

exit 0;


