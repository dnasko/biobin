#!/usr/bin/perl
use strict;
use POSIX;
use LWP::Simple;
$|=1;      # forces print output to be sent to screen in real-time

#--------------------------HEADER---------------------------
# DJN 11Apr2011
# Homework 03
# Objectives:	(1) Read the NT FASTA file
# 		(2) Align the predefined domain agaist the two sequences.

#----------------------USER VARIABLES-----------------------

#my $infile = "/Users/dannasko/Desktop/BPaul_ANME_BULK_peptide/ANME_SIP_BULK.filtered.cd-hit-454_20.pep";  

my @INFILES;
my $FastPDir = "/Users/dannasko/Desktop/BPaul_ANME_BULK_peptide/";
opendir(DIR, $FastPDir); @INFILES= readdir(DIR);


my $infile = "/Users/dnasko/Desktop/tmp.fsa";
my $TargetSeq = "TTTGCCTTTGCCCCTGCCCCTGACTC";


#---------------------GLOBAL VARIABLES----------------------

my @FILE;        # input array to hold file contents
my %NTs;         # Hash-Array to hold each orf name & sequence
my @M;           # alignment matrix; filled by similarity scores
my $match = 1;          # match bonus
my $g = -3;                # gap penalty
my $mismatch = -1;   # mismatch penalty

#-----------------------------------------------------------
#---------------------------MAIN----------------------------
#-----------------------------------------------------------


print "\n\nBeginning your BLAST . . . \n\n";

# 1. Input FASTA and make protein sequences . . . . 
#    foreach my $file (@INFILES)
#    {
#	&ReadFasta("/Users/dannasko/Desktop/BPaul_ANME_BULK_peptide/$file");
#	
#    }
	&ReadFasta($infile);

# 2. Iteratively execute the similarity scoring subroutine: 
	my $max = -99999;
	my $seq1 = $TargetSeq;
	foreach my $gene (keys %NTs)
	{	my $seq2 = $NTs{$gene};
	 	my $score = &Similarity($seq1,$seq2);
		if ($score > $max)
		{	$max = $score;
			print "\n\n---------------------------------\n";
			print "      Alignment: $gene\n      Score= $score\n";
			foreach my $x (&Alignment($seq1,$seq2)) 
			{	print "                 ",$x,"\n"; }
		}
		else
		{	print ""; } # just "." so you know the program is still runnning
	}

print "\n\n    Process Complete...\n\n";
#-----------------------------------------------------------
#------------------------SUBROUTINES------------------------
#-----------------------------------------------------------
sub ReadFasta
{   my $file = $_[0];
	$/=">";
	open(FASTA,"<$file") or die "\n\n\n Nada $file\n\n\n";
	@FILE=<FASTA>;
	close(FASTA);
	shift(@FILE); 
	foreach my $orf (@FILE)
	{	my @Lines = split(/\n/,$orf);
		my $name = $Lines[0];
		my $seq = "";
		foreach my $i (1..$#Lines)
		{	$seq .= $Lines[$i]; }
		$seq =~ s/>//;
		$NTs{$name} = $seq;
	}
	$/="\n"; # reset input break character
}
# - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - -
sub Similarity 
{	# call &Similarity($seq1, $seq2)
	# Determines score of best alignment of strings $seq1 and $seq2
	# Score values are stored in @M
	# Returns max alignment score
	# Calls subroutines &ID and &MAX
	#. . . . . . . . . . . . . . . . .
    my($s,$t) = @_;  # sequences to be aligned.
    foreach my $i (0..length($s)) { $M[$i][0] = $g * $i; }
    foreach my $j (0..length($t)) { $M[0][$j] = $g * $j; }
	
    foreach my $i (1..length($s)) 
	{	foreach my $j (1..length($t)) 
		{	my $p =  &ID(substr($s,$i-1,1),substr($t,$j-1,1));
			$M[$i][$j] = &MAX($M[$i-1][$j] + $g, $M[$i][$j-1] + $g,$M[$i-1][$j-1] + $p);
		}
    }
    return ( $M[length($s)][length($t)] );
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub ID 
{  # call &ID(char1,char2)
    my ($aa1, $aa2) = @_;
    return ($aa1 eq $aa2)?$match:$mismatch;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub MAX
{	# find max value
	# call &MAX(default value, other values . . . )
	my ($m,@l) = @_;
    foreach my $x (@l) { $m = $x if ($x > $m); }
    return $m;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub Alignment
{	# call &Alignment(seq1,seq2)
    my ($s,$t) = @_;  ## sequences to be aligned.
    my ($i,$j) = (length($s), length($t));
    return ( "-"x$j, $t) if ($i==0);
    return ( $s, "-"x$i) if ($j==0);
    my ($sLast,$tLast) = (substr($s,-1),substr($t,-1));
    
    if ($M[$i][$j] == $M[$i-1][$j-1] + &ID($sLast,$tLast)) 
	{ ## Case 1: last letters are paired in the best alignment
		my ($sa, $ta) = &Alignment(substr($s,0,-1), substr($t,0,-1));
		return ($sa . $sLast , $ta . $tLast );
    } 
	elsif ($M[$i][$j] == $M[$i-1][$j] + $g) 
	{ ## Case 2: last letter of the first string is paired with a gap
		my ($sa, $ta) = &Alignment(substr($s,0,-1), $t);
		return ($sa . $sLast , $ta . "-");
    } 
	else 
	{ ## Case 3: last letter of the 2nd string is paired with a gap
		my ($sa, $ta) = &Alignment($s, substr($t,0,-1));
		return ($sa . "-" , $ta . $tLast );
    }
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#----------------------------EOF----------------------------
