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

use lib '/home/wommacklab/library/lib64/perl5';
use strict;
use Getopt::Long;
use File::Basename;
use Pod::Usage;
use String::Approx 'amatch';

## ARGS WITH NO DEFAULTS
my ($fasta,$adapter,$outfile,$barcode,$trim,$help,$manual);

## ARGS WITH DEFAULTS
my $identity = "1.0";
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
my $version = "2.4"; ## DJN 10Sep2014 two bug updates
my @adapters;
my %adp_counts;
my %trim_coord;
my %is_reverse;

## Logging
print "
 demultiplex.pl version $version
 infile: $fasta
 adapter lookup: $adapter
 writing outputs to: $outdir
 matching at: $identity
 trim: ";
if ($trim) { $trim = 1; print "YES\n\n"}
else {$trim = 0; print "No.\n\n"}

## Read FASTA file into a hash
my %Fasta = read_fasta_hash($fasta);

## Creating output / working directories
print `mkdir -p $outdir`;
print `mkdir -p $outdir/$identity`;
print `mkdir -p $outdir/$identity/demltiplxd`;
print `mkdir -p $outdir/$identity/nil`;

## Preprocessing / Hash construction
my $id_string = form_id_string($identity);
my %AmbigBases = construct_hash();

## Gathering up the adapters
open(IN,"<$adapter") || die "\n Error! Cannot open or find the adapter file $adapter\n";
while(<IN>) {
    chomp;
    my @col = split(/\t/, $_);
    unless (scalar(@col) == 2) { die " Error: Make sure your adapter lookup file is delimmited by tabs, not spaces\n\n ";}
    my $name = $col[0];
    my $seq = uc($col[1]);
    # print $name . " <-> " . $seq . "\n";
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
		    my $local_count = 0;
		    my @keys = sort { $Combo{$a} cmp $Combo{$b} } keys(%Combo);
		    foreach my $j (@keys) {
			$Combo{$j} = $Combo{$j} . ${$AmbigBases{$Seq[$i]}}[$local_count];
			$local_count++;
			if ($local_count == scalar(@{$AmbigBases{$Seq[$i]}})) { $local_count = 0; } 
		    }
		}
		else {  die "\n Error: Primer/Adapter contains invalid ambgious base:\n$Seq[$i] $i \n\n Only A,C,G,T,W,S,M,K,R,Y,B,D,H,V, and N are acceptable.\n\n"; } 
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

##
## Now search for each of the adapters
##
for (my $i=0; $i<scalar(@adapters);$i++) {
    my @EachAdp = $adapters[$i];
    my $adapter_name = $EachAdp[0][0];
    my %found;
    for(my $j=1;$j<scalar(@{$adapters[$i]});$j++) {
    	my $adapter_sequence = ${$adapters[$i]}[$j];
	my @found = find_adapt($adapter_sequence);
	foreach my $i (@found) {
	    unless (exists $found{$i}) {
		$found{$i} = 1;
		$adp_counts{$adapter_name}++;
	    }
	}
    }
    my $dump = dump_results($adapter_name,\%found);
}

## Spit out how many reads we found for each adapter. 
##
print STDOUT " Reads found for each adapter:\n";
foreach my $adp (@adapters) {
    if (exists $adp_counts{$$adp[0]}) {
	print STDOUT "\t$$adp[0]\t$adp_counts{$$adp[0]}\n";
    }
    else {
	print STDOUT "\t$$adp[0]\t0\n";
    }
}
print STDOUT "\n\n";
if ($trim == 1) {
    print STDOUT " Trimming Location Frequency:\n";
    foreach my $coord (sort {$a<=>$b} keys %trim_coord) {
	print STDOUT " $coord\t$trim_coord{$coord}\n";
    }
}
print STDOUT "\n\n";

## SUBROUTINES
##############################
## read_fasta_hash($infile)
## Reads a FASTA file into a hash
## RETURNS: A hash containing a FASTA file
sub read_fasta_hash
{
    my $infile = $_[0];
    my %tmp_fasta;
    my ($tmp_header,$tmp_sequence);
    my $counter = 0;
    if ($infile =~ m/\.gz$/) {
        open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the FASTA: $infile\n\n";
    }
    else {
        open(IN,"<$infile") || die "\n\n Cannot open the FASTA: $infile\n\n";
    }
    while(<IN>) {
        chomp;
	if ($counter == 0) { 
	    $tmp_header = $_;
	    $tmp_header =~ s/^>//;
	}
	elsif ($_ =~ m/^>/) {
	    if (length($tmp_sequence) > $window*2) {
		$tmp_fasta{$tmp_header} = $tmp_sequence;
	    }
	    $tmp_sequence = "";
	    $tmp_header = $_;
	    $tmp_header =~ s/^>//;
	}
	else {
	    $tmp_sequence = $tmp_sequence . $_;
	}
	$counter++;
    }
    close(IN);
    $tmp_fasta{$tmp_header} = $tmp_sequence;
    return(%tmp_fasta);
}
##############################
## head($seq, 40);
## Grabs the first n chars from string m
## RETURNS: first n chars from string m
sub head
{
    my $string = $_[0];
    my $chars_to_grab = $_[1];
    my $head = substr $string, 0, $chars_to_grab;
    return($head);
}
##############################
## tail($seq, 50)
## Grabs the last n chars from string m
## RETURNS: last n chars from string m
sub tail
{
    my $string = $_[0];
    my $chars_to_grab =$_[1];
    $chars_to_grab *= -1;
    my $tail = substr $string, $chars_to_grab;
    return($tail);
}
##############################
## revcomp($nt_seq)
## Reverse compliment a nucleotide sequence
## RETURNS: The reverse compliment of a NT sequence
sub revcomp
{
    my $nulceotide_sequence = $_[0];
    my $rev_comp_seq = scalar reverse $nulceotide_sequence;
    $rev_comp_seq =~ tr/ATGCatgc/TACGTACG/;
    return($rev_comp_seq);
}
##############################
## form_id_string($float_point_identity)
## format the ID string for String::Approx
## RETURNS: Formatted ID string for String::Approx
sub form_id_string
{
    my $id = $_[0];
    my $string = 100 - ($id * 100);
    $string = $string . "%";
    return $string;
}
##############################
## construct_hash()
## Creates a hash of arrays containing ambiguous bases
## RETURNS: A hash of arrays of ambiguous bases
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
##############################
## find_adapt($adapter_seq)
## Search for adapter in %Fasta
## %Fasta MUST already exist!
## RETURNS: Array of headers that have adapter.
sub find_adapt
{
    my $adapter_sequence = $_[0];
    my @matches;
    foreach my $header (keys %Fasta) {
	my $sequence = $Fasta{$header};
	my $rev_sequence = revcomp($sequence);
	my $head_for = head($sequence, $window);
	my $tail_for = tail($sequence, $window);
	my $head_rev = head($rev_sequence, $window);
	my $tail_rev = tail($rev_sequence, $window);
	if (amatch ($adapter_sequence,[ $id_string ], $head_for)) {
	    push(@matches, $header);
	    if ($trim == 1) { my $trimmed_seq = trim_adapter($adapter_sequence, $header, 1);
			      $Fasta{$header} = $trimmed_seq;}
	}
	elsif (amatch ($adapter_sequence,[ $id_string ], $tail_for)) {
	    push(@matches, $header);
	    if ($trim == 1) { my $trimmed_seq = trim_adapter($adapter_sequence, $header, 2);
			      $Fasta{$header} = $trimmed_seq;}
	}
	elsif (amatch ($adapter_sequence,[ $id_string ], $head_rev)) {
            push(@matches, $header);
	    if ($trim == 1) { my $trimmed_seq = trim_adapter($adapter_sequence, $header, 3);
			      $Fasta{$header} = $trimmed_seq;}
	    $is_reverse{$header} = 1;
	}
	elsif (amatch ($adapter_sequence,[ $id_string ], $tail_rev)) {
            push(@matches, $header);
	    if ($trim == 1) { my $trimmed_seq = trim_adapter($adapter_sequence, $header, 4);
			      $Fasta{$header} = $trimmed_seq;}
	    $is_reverse{$header} = 1;
	}
    }
    return(@matches);
}
##############################
## dump_results($adapter_name, %found)
## Dump out results for a hash
## RETURNS: Nothing. Just writes outputs. 
sub dump_results
{
    my $adapter_name = $_[0];
    my %found = %{$_[1]};
    my $output_good_file = "$outdir/$identity/demltiplxd/" . $adapter_name . ".fasta";
    my $output_nil_file = "$outdir/$identity/nil/" . $adapter_name . ".nil.fasta";
    open(OUTG,">$output_good_file") || die "Cannot write to the following file: $outdir/$identity/demltiplxd/$adapter_name.fasta\n\n";
    open(OUTN,">$output_nil_file") || die "Cannot write to the following: $outdir/$identity/nil/$adapter_name.nil.fasta\n\n";
    foreach my $seq (keys %Fasta) {
	if (exists $found{$seq}) {
	    if (exists $is_reverse{$seq}) {
		my $rev_seq = revcomp($Fasta{$seq});
		print OUTG ">$seq\n$rev_seq\n";
                delete $Fasta{$seq};
		delete $is_reverse{$seq};
	    }
	    else {
		print OUTG ">$seq\n$Fasta{$seq}\n";
		delete $Fasta{$seq};
	    }	
	}
	else {
	    print OUTN ">$seq\n$Fasta{$seq}\n";
	}
    }
    close(OUTG);
    close(OUTN);
}
##############################
## trim_adapter($adapter_seq, $header_name, 2)
## Trim the adapter sequence from the sequence of interest
## %Fasta must exist already!
## Flag meanings:
##   1 = primer at 5' end in fr orientation
##   2 = primer at 3' end in fr orientation
##   3 = primer at 5' end in rc orientation
##   4 = primer at 3' end in rc orientation
## RETURNS: Trimmed and reoriented sequence.
sub trim_adapter
{
    my $adapter_seq = $_[0];
    my $header = $_[1];
    my $flag = $_[2];
    my $sequence = $Fasta{$header};
    my $not_at_beginning = 0; # set as false
    if ($flag == 3 || $flag == 4) {	$sequence = revcomp($sequence);    }
    if ($flag == 1 || $flag == 3) { ## If at the beginning of the seq
	my $splice_position = find_splice($adapter_seq,$sequence,0,-1);
	my $trimmed_sequence;
	if ($splice_position < 0) {    $splice_position = find_splice($adapter_seq,$sequence,1,-1); }
	if ($splice_position < 0) {    $splice_position = find_splice($adapter_seq,$sequence,2,-1); }
	if ($splice_position < 0) { $not_at_beginning = 1; }
	else {
	    $splice_position += length($adapter_seq) - 2;
	    $trimmed_sequence = substr $sequence, $splice_position;
	    $trim_coord{$splice_position}++;
	}
	## Now try to trim the RC adapter on the 3' end.
	my $rev_adapter_seq = revcomp($adapter_seq);
	$splice_position = find_splice($rev_adapter_seq,$trimmed_sequence,0,1);
	if ($splice_position > 0) {    $splice_position = find_splice($rev_adapter_seq,$trimmed_sequence,1,1); }
	if ($splice_position > 0) {    $splice_position = find_splice($rev_adapter_seq,$trimmed_sequence,2,1); }
	if ($splice_position > 0) {
	    if ($not_at_beginning == 1) {
		die " \n Error! Unable to trim this sequence: $header\n";
	    }
	    else {
		return($trimmed_sequence);
	    }
	}
	else {
	    $trimmed_sequence = substr $trimmed_sequence, 0, length($trimmed_sequence)+$splice_position;
	    $trim_coord{$splice_position}++;
	    return($trimmed_sequence);
	}
    }
    else {
	my $splice_position = find_splice($adapter_seq,$sequence,0,1);
	my $trimmed_sequence;
	if ($splice_position > 0) {    $splice_position = find_splice($adapter_seq,$sequence,1,1); }
	if ($splice_position > 0) {    $splice_position = find_splice($adapter_seq,$sequence,2,1); }
	if ($splice_position > 0) {    $not_at_beginning = 1; }
	else {
	    $trimmed_sequence = substr $sequence, 0, length($sequence)+$splice_position;
	    $trim_coord{$splice_position}++;
	}
	## Now try to trim RC adapter on 5' end.
	my $rev_adapter_seq = revcomp($adapter_seq);
	$splice_position = find_splice($rev_adapter_seq,$trimmed_sequence,0,-1);
	if ($splice_position < 0) {    $splice_position = find_splice($adapter_seq,$trimmed_sequence,1,-1); }
        if ($splice_position < 0) {    $splice_position = find_splice($adapter_seq,$trimmed_sequence,2,-1); }
	if ($splice_position < 0) {
	    if ($not_at_beginning == 1) {
		die " \n Error! Unable to trim this sequence: $header\n";
	    }
	    else {
		return($trimmed_sequence);
	    }
	}
	else {
	    $splice_position += length($adapter_seq) - 2;
	    $trimmed_sequence = substr $trimmed_sequence, $splice_position;
	    $trim_coord{$splice_position}++;
	    return($trimmed_sequence);
	}
    }
}
##############################
## find_splice($adapter, $sequence, $sliding_extension, $splice_position)
## Find where in the sequence an adapter is
## RETURNS: position to splice
sub find_splice
{
    my $adapter_seq = $_[0];
    my $sequence = $_[1];
    my $sliding_extension = $_[2];
    my $splice_position = $_[3];
    if ($splice_position < 0) {
	for (my $i=0;$i<=$window-length($adapter_seq)+$sliding_extension;$i++) {
	    my $sliding_window = substr $sequence, $i, length($adapter_seq)+$sliding_extension;
	    if (amatch ($adapter_seq,[ $id_string ], $sliding_window)) {
		$splice_position = $i;
	    }
	}
    }
    else {
	for (my $i=-length($adapter_seq);$i>=-$window-$sliding_extension;$i--) {
	    # print "STUFF: $i\t$sequence\n";
	    my $sliding_window = substr $sequence, $i, length($adapter_seq)+$sliding_extension;
            if (amatch ($adapter_seq,[ $id_string ], $sliding_window)) {
                $splice_position = $i;
            }
        }
    }
    return($splice_position);
}

## donions
exit 0;
