package SequenceIO;
use strict;
use warnings;
 
## SequenceIO.pm Version 1.1
## Revision History:
##   20 Dec 2012 -- ADDED base code
##   28 Jan 2013 -- ADDED read_fasta_hash
##   30 Jan 2013 -- ADDED split_fasta_hashref

## split_multifasta
## A subroutine which will split a FASTA file
##  into an array of hash references (AoH) which contains
##  n hash references
sub split_fasta_hashref
{
    my $fasta_input_file = $_[0];
    my $num_splits = $_[1];
    ## Declare and initialize variable
    my @AoH;
    my $num_seqs = `fgrep -c ">" $fasta_input_file`;
    my $seq_per_split = $num_seqs / $num_splits;
    unless ($seq_per_split == int($seq_per_split)) {
	my $remainder = $seq_per_split - int($seq_per_split);
	$seq_per_split += (1-$remainder);
    }
    open(IN,"<$fasta_input_file") || die "\n\n Error! Cannot open or find the input fasta file $fasta_input_file\n\n";
    $/='>';
    my @fasta_file_data = <IN>;
    close(IN);
    shift(@fasta_file_data);
    my $sequence_counter = 1;
    my $global_sequence_counter = 1;
    my $hash = {};
    foreach my $sequence (@fasta_file_data) {
        if ($sequence_counter <= $seq_per_split) {
	    my @data = split('\n',$sequence);
	    my $header = $data[0];
	    my $seq = '';
	    foreach my $i (1..$#data) {
		$seq .= $data[$i];
	    }
	    $seq =~ s/>//;
	    $hash->{$header} = $seq;
	    if ($global_sequence_counter == $num_seqs) {
		push @AoH, $hash;
	    }
	}
	else {
	    $sequence_counter = 1;
	    push @AoH, $hash;
	    $hash = {};
	    my @data = split('\n',$sequence);
            my $header = $data[0];
            my $seq = '';
            foreach my $i (1..$#data) {
                $seq .= $data[$i];
            }
            $seq =~ s/>//;
            $hash->{$header} = $seq;
	}
	$sequence_counter++;
	$global_sequence_counter++;
    }
    $/="\n";
    return @AoH;
}

## read_fasta_hash
## A subroutine which reads FASTA files into a hash
sub read_fasta_hash
{
    my $fasta_input_file = $_[0];
    ## Declare and initialize variables
    my %SEQs = ();
    open(IN,"<$fasta_input_file") || die "\n\n Error! Cannot open or find the input fasta file $fasta_input_file\n\n";
    $/='>';
    my @fasta_file_data = <IN>;
    close(IN);
    shift(@fasta_file_data);
    foreach my $sequence (@fasta_file_data) {
	my @data = split('\n',$sequence);
	my $header = $data[0];
	my $seq = '';
	foreach my $i (1..$#data) {
	    $seq .= $data[$i];
	}
	$seq =~ s/>//;
	$SEQs{$header} = $seq;
    }
    $/="\n";
    return %SEQs;
}
## read_fasta_hash_strip
## A subroutine which reads FASTA files into a hash
## BUT strips the header after the first instance of a space
sub read_fasta_hash_strip
{
    my $fasta_input_file = $_[0];
    ## Declare and initialize variables
    my %SEQs = ();
    open(IN,"<$fasta_input_file") || die "\n\n Error! Cannot open or find the input fasta file $fasta_input_file\n\n";
    $/='>';
    my @fasta_file_data = <IN>;
    close(IN);
    shift(@fasta_file_data);
    foreach my $sequence (@fasta_file_data) {
	my @data = split('\n',$sequence);
	my $header = $data[0];
	$header =~ s/ .*//;
	my $seq = '';
	foreach my $i (1..$#data) {
	    $seq .= $data[$i];
	}
	$seq =~ s/>//;
	$SEQs{$header} = $seq;
    }
    $/="\n";
    return %SEQs;
}

## get_file_data
## A subroutine to get data from a file given its filename
sub get_file_data
{
    my ($filename) = @_;
    ## Initialize variables
    my @filedata = ( );
    open(GET_FILE_DATA, $filename) || die "\n\n Cannot open file '$filename':$!\n\n";
    @filedata = <GET_FILE_DATA>;
    close GET_FILE_DATA;
    return @filedata;
}

## extract_sequence_from_fasta_data
## A subroutine to extract FASTA sequence data from an array
sub extract_sequence_from_fasta_data
{
    my(@fasta_file_data) = @_;
    ## Declare and initialize variables
    my $sequence = '';
    foreach my $line (@fasta_file_data) {
        ## discard blank line
        if ($line =~ /^\s*$/) {
            next;
        }
        ## discard comment line
        elsif ($line =~ /^\s*#/) {
            next;
        }
        ## discard fasta header line
        elsif($line =~ /^>/) {
            next;
        }
        ## keep line, add to sequence string
        else {
            $sequence .= $line;
        }
    }
    ## remove non-sequence data (in this case, whitespace) from $sequence string
    $sequence =~ s/\s//g;
    return $sequence;
}

## print_sequence
## A subroutine to format and print sequence data
sub print_sequence
{
    my($sequence, $length) = @_;
    ## Print sequence in lines of $length
    for ( my $pos = 0 ; $pos < length($sequence) ; $pos += $length ) {
        print substr($sequence, $pos, $length), "\n";
    }
}

1;
