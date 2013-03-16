package SequenceStats;
use strict;
use warnings;
use threads::shared;
 
## SequenceStats.pm Version 1.0
## Revision History:
##   31 Jan 2013 -- ADDED base code

our %GC_thread : shared;

## gc_content
## A subroutine which will caclulate gc content
##  from a FASTA file which has been read into
##  a hash already
## Ouputs: a hash of headers and gc content
sub gc_content
{
    my $fasta_input_file = $_[0];
    ## Declare and initialize variable
    my %GC;
    foreach my $sequence (keys %$fasta_input_file) {
	my $sequence_string = $fasta_input_file->{$sequence};
	my $gc = $sequence_string =~ tr/GCgc/GCgc/;
	if ($gc == 0) {
	    $GC{$sequence} = 0;
	    $GC_thread{$sequence} = 0;
	}
	else {
	    my $gc_content = $gc / length($sequence_string);
	    $GC{$sequence} = $gc_content;
	    $GC_thread{$sequence} = $gc_content;
	}
    }
    return %GC;
}

## read_fasta_hash
## A subroutine which reads FASTA files into a hash


1;
