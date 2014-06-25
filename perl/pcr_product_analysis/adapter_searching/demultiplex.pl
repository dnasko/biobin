#!/usr/bin/perl -w

# MANUAL FOR demultiplex.pl

=pod

=head1 NAME

 demultiplex.pl -- searches through a FASTA file for adapters and splits them into separate files.

=head1 SYNOPSIS

 demultiplex.pl --adapter=/Path/to/adapters.lookup --fasta=/Path/to/infile.fasta --window=30 --identity=1.0 --outdir=/Path/to/outdir --trim
             [--help] [--manual]

=head1 DESCRIPTION

This script was adapted from an older bit of code that performed
a similar function. Specifically it searches through the input
FASTA file for each of the adapter sequences in the adapter
lookup file. The adapter lookup file should have one adapter 
sequence per line. On each line it will only contain "adapter
name" followed by a tab then "sequence." This script can handle
ambiguos bases a-okay. By default it will not trim off the adatper
region; this may be altered with the -trim flag.

=head1 OPTIONS

=over 3

=item B<-f, --fasta>=FILENAME

Input file in FASTA format. (Required)

=item B<-a, --adapter>=FILENAME

The adapter lookup file. One per line. "Name" [Tab] "ATGCTG" [\n] (Required)

=item B<-w, --window>=FILENAME

How many bases into the sequence would you like to search? (Default=30)

=item B<-o, --outdir>=OUTPUT_DIR

Directory where you want outputs written to. (Default=./demultiplex_out)

=item B<-i, --identity>=FLOAT

What percent similarity must the input adapter match. (Default = 1.0)

=item B<-t, --trim>

Trim off the adapter found. (Optional)

=item B<-h, --help>

Displays the usage message. (Optional)

=item B<-m, --manual>

displays the full manual. (Optional)

=back

=head1 DEPENDENCIES

Requires the following Perl libraries:

String::Approx

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
use String::Approx 'amatch';

## ARGS WITH NO DEFAULTS
my ($fasta,$adapter,$outfile,$barcode,$trim,$help,$manual);

## ARGS WITH DEFAULTS
my $identity = 1.0;
my $window   = 30;
my $outdir   = "./demultiplex_out";

GetOptions (
                     "f|fasta=s"    =>  \$fasta,
                     "a|adapter=s"  =>  \$adapter,
                     "w|window=i"   =>  \$window,
                     "o|outdir=s"   =>  \$outdir,
                     "i|identity=s" =>  \$identity,
                     "t|trim"       =>  \$trim,
                     "h|help"       =>  \$help,
                     "m|manual"     =>  \$manual    );

## VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage(-verbose => 1)  if ($help);
pod2usage( -msg  => "\n\nERROR: Required arguments --fasta not found\n\n", -exitval => 2, -verbose => 1)  if (! $fasta);
pod2usage( -msg  => "\n\nERROR: Required arguments --adapter not found\n\n", -exitval => 2, -verbose => 1)  if (! $adapter);
pod2usage( -msg  => "\n\nERROR: --identity must be an int between 0 and 1\n\n", -exitval => 2, -verbose => 1)  if ( $identity > 1 || $identity < 0);

## Global Variables
my $version = "1.0";
my @adapters;

## Logging
print "
 demultiplex.pl version $version
 infile: $fasta
 adapter lookup: $adapter
 writing outputs to: $outdir
 matching at: $identity
 trim: ";
if ($trim) { $trim = 1; print "YES\n\n"}
else {print "No.\n\n"}

## Creating output / working directories
print `mkdir -p $outdir`;
print `mkdir -p $outdir/$identity`;

## Preprocessing / Hash construction
my $id_string = form_id_string($identity);
my %AmbigBases = construct_hash();

## Gathering up the adapters
open(IN,"<$adapter") || die "\n Error! Cannot open or find the adapter file $adapter\n";
while(<IN>) {
    chomp;
    my @col = split(/\t/, $_);
    my $name = $col[0];
    my $seq = uc($col[1]);
    my $valid_bases = $seq =~ tr/ATGC/ATGC/;
    if ($valid_bases == length($seq)) { ## if the primer / adapter has no ambiguous bases
	my @tmp = ($name, $seq);
	push @adapters, [@tmp];
    }
    else {                              ## if the primer / adapter HAS ambiguos bases 
	my %Combo;
	my @Seq = split(//, $seq);
	my $combos = 1;
	foreach my $base (@Seq) {
	    if (exists $AmbigBases{$base}) {
		$combos *= scalar(@{$AmbigBases{$base}});
	    }
	}
	for (my $i=1; $i<=$combos; $i++) {
	    $Combo{$i} = "";
	}
	for(my $i=0;$i<scalar(@Seq);$i++) {
	    if ($Seq[$i] !~ m/A|T|C|G/) {
		if (exists $AmbigBases{$Seq[$i]}) {
		    my $local_counter = 0;
		    for (my $j=1; $j <= $combos; $j++) {
			if ($local_counter >= scalar(@{$AmbigBases{$Seq[$i]}})) {
			    $local_counter = 0;
			    $Combo{$j} = $Combo{$j} . ${$AmbigBases{$Seq[$i]}}[$local_counter];
			}
			else {
			    $Combo{$j} = $Combo{$j} . ${$AmbigBases{$Seq[$i]}}[$local_counter];
			}
			$local_counter++;
		    }  
		}
		else {  die "\n Error: Primer/Adapter contains invalid ambgious base: $Seq[$i]\n Only A,C,G,T,W,S,M,K,R,Y,B,D,H,V, and N are acceptable.\n\n"; } 
	    }
	    else {
		for (my $j=1;$j <= $combos; $j++) {
		    $Combo{$j} = $Combo{$j} . $Seq[$i];
		}
	    }
	}
	my @tmp = ($name);
	foreach my $ambig_adapter (sort {$a <=> $b} keys %Combo) {
	    push (@tmp, $Combo{$ambig_adapter});
	}
	push (@adapters, [@tmp]);
    }
}
close(IN);


## Now search for each of the adapters
foreach my $adp (@adapters) {
    print "$$adp[0]\n";
    for(my $i=1;$i<scalar(@$adp);$i++) {
	print "\t$$adp[$i]\n";
    }
}


sub form_id_string
{
    my $id = $_[0];
    my $string = 100 - ($id * 100);
    $string = $string . "%";
    return $string;
}

sub construct_hash
{
    my %hash = (
	W => [ 'A', 'T' ],
	S => [ 'C', 'G' ],
	M => [ 'A', 'C' ],
	K => [ 'G', 'T' ],
	R => [ 'A', 'G' ],
	Y => [ 'C', 'T' ],
	B => [ 'C', 'G', 'T' ],
	D => [ 'A', 'G', 'T' ],
	H => [ 'A', 'C', 'T' ],
	V => [ 'A', 'C', 'G' ],
	N => [ 'A', 'C', 'G', 'T' ]
	);
    return(%hash);
}

exit 0;
