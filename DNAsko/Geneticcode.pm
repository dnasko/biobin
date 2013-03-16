package Geneticcode;
use strict;
use warnings;

## Geneticcode.pm Version 2.0

my (%genetic_code) = (
    'TCA'   =>  'S',    ## SERINE
    'TCC'   =>  'S',    ## SERINE
    'TCG'   =>  'S',    ## SERINE
    'TCT'   =>  'S',    ## SERINE
    'TTC'   =>  'F',    ## PHENYLALANINE
    'TTT'   =>  'F',    ## PHENYLALANINE
    'TTA'   =>  'L',    ## LEUCINE
    'TTG'   =>  'L',    ## LEUCINE
    'TAC'   =>  'Y',    ## TYROSINE
    'TAT'   =>  'Y',    ## TYROSINE
    'TAA'   =>  '*',    ## STOP
    'TAG'   =>  '*',    ## STOP
    'TGC'   =>  'C',    ## CYSTEINE
    'TGT'   =>  'C',    ## CYSTEINE
    'TGA'   =>  '*',    ## STOP
    'TGG'   =>  'W',    ## TRYTOPHAN
    'CTA'   =>  'L',    ## LEUCINE
    'CTC'   =>  'L',    ## LEUCINE
    'CTG'   =>  'L',    ## LEUCINE
    'CTT'   =>  'L',    ## LEUCINE
    'CCA'   =>  'P',    ## PROLINE
    'CCC'   =>  'P',    ## PROLINE
    'CCG'   =>  'P',    ## PROLINE
    'CCT'   =>  'P',    ## PROLINE
    'CAC'   =>  'H',    ## HISTIDINE
    'CAT'   =>  'H',    ## HISTIDINE
    'CAA'   =>  'Q',    ## GLUTAMINE
    'CAG'   =>  'Q',    ## GLUTAMINE
    'CGA'   =>  'R',    ## ARGININE
    'CGC'   =>  'R',    ## ARGININE
    'CGG'   =>  'R',    ## ARGININE
    'CGT'   =>  'R',    ## ARGININE
    'ATA'   =>  'I',    ## ISOLEUCINE
    'ATC'   =>  'I',    ## ISOLEUCINE
    'ATT'   =>  'I',    ## ISOLEUCINE
    'ATG'   =>  'M',    ## METHIONINE
    'ACA'   =>  'T',    ## THREONINE
    'ACC'   =>  'T',    ## THREONINE
    'ACG'   =>  'T',    ## THREONINE
    'ACT'   =>  'T',    ## THREONINE
    'AAC'   =>  'N',    ## ASPARAGINE
    'AAT'   =>  'N',    ## ASPARAGINE
    'AAA'   =>  'K',    ## LYSINE
    'AAG'   =>  'K',    ## LYSINE
    'AGC'   =>  'S',    ## SERINE
    'AGT'   =>  'S',    ## SERINE
    'AGA'   =>  'R',    ## ARGININE
    'AGG'   =>  'R',    ## ARGININE
    'GTA'   =>  'V',    ## VALINE
    'GTC'   =>  'V',    ## VALINE
    'GTG'   =>  'V',    ## VALINE
    'GTT'   =>  'V',    ## VALINE
    'GCA'   =>  'A',    ## ALANINE
    'GCC'   =>  'A',    ## ALANINE
    'GCG'   =>  'A',    ## ALANINE
    'GCT'   =>  'A',    ## ALANINE
    'GAC'   =>  'D',    ## ASPARTIC ACID
    'GAT'   =>  'D',    ## ASPARTIC ACID
    'GAA'   =>  'E',    ## GLUTAMIC ACID
    'GAG'   =>  'E',    ## GLUTAMIC ACID
    'GGA'   =>  'G',    ## GLYCINE
    'GGC'   =>  'G',    ## GLYCINE
    'GGG'   =>  'G',    ## GLYCINE
    'GGT'   =>  'G'     ## GLYCINE
);

## codon2aa
## A subroutine to translate a DNA 3-charecter codon to an amino acid
##      Version 1.0, using hash lookup
sub codon2aa
{
    my($codon) = @_;
    $codon = uc $codon;
    if (exists $genetic_code{$codon}) {
        return $genetic_code{$codon};
    }
    else {
        die "\n\n Bad codon: $codon !!!\n\n";
    }
}

## dna2peptide
## A subroutine to translate DNA sequence into a peptide
sub dna2peptide
{
    my ($dna) = @_;
    
    ## Initialize variables
    my $protein = '';
    
    ## Translate each three-base codon to an amino acid, and append to a protein
    for(my $i=0; $i < (length($dna) - 2) ; $i += 3) {
        $protein .= codon2aa( substr($dna,$i,3) );
    }
    return $protein;
}

## translate_frame
## A subroutine to translate a frame of DNA

sub translate_frame
{
    my ($seq, $start, $end) = @_;
    my $protein;
    ## To make this subroutine easier to use, you won't need to specify
    ## the end point -- it will just go to the end of the sequence
    ## by defualt.
    unless($end) {
        $end = length($seq);
    }
    ## Finally we calculate and return the translation
    return dna2peptide ( substr ( $seq, $start - 1, $end - $start + 1) );
}

1;