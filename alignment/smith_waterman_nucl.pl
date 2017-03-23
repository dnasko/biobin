#!/usr/bin/perl -w

# MANUAL FOR smith_waterman.pl

=pod

=heda1 NAME

smith_waterman.pl -- the Smith-Waterman algorithm for local sequence alignment

=head1 SYNOPSIS

 smith_waterman.pl -query /Path/to/infile.fasta -db /Path/to/db.fasta -outroot /Path/to/output
                     [--help] [--manual]

=head1 DESCRIPTION

Perl implimentation of the Smith-Waterman algorithm for local sequence alignment.

=head1 OPTIONS

=over 3

=item B<-q, --query>=/Path/to/infile.fasta

Input query FASTA file. (Required)

=item B<-d, --db>=/Path/to/db.fasta

Input database FASTA file. (Required)

=item B<-o, --outroot>=/Path/to/outroot

Path and root of outfiles. Two will be created. (Required)

=item B<-h, --help>

Displays the usage message.  (Optional)

=item B<-m, --manual>

Displays full manual.  (Optional)

=back

=head1 DEPENDENCIES

Requires the following Perl libraries:

POSIX

=head1 AUTHOR

Written by Daniel Nasko,
Center for Bioinformatics and Computational Biology Core Facility, University of Delaware.

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
use POSIX;

## Arguments with no default
my ($query,$db,$outroot,$help,$manual);

GetOptions (
                                "q|query=s"     =>      \$query,
                                "d|db=s"        =>      \$db,
                                "o|outroot=s"   =>      \$outroot,
                                "h|help"        =>      \$help,
                                "m|manual"      =>      \$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage(-verbose => 1)  if ($help);
pod2usage( -msg  => "\n\nERROR!  Required argument --query\n\n", -exitval => 2, -verbose => 1)  if (! $query );
pod2usage( -msg  => "\n\nERROR!  Required argument --db\n\n", -exitval => 2, -verbose => 1)  if (! $db );
pod2usage( -msg  => "\n\nERROR!  Required argument --outroot\n\n", -exitval => 2, -verbose => 1)  if (! $outroot );

# Smith-Waterman   Algorithm
my %SUBJECT = ReadFasta($db);
my @Subject = ReadFastaHeader($db);
my %QUERY   = ReadFasta($query);
my @Query   = ReadFastaHeader($query);

# scoring scheme
my $MATCH     =  1; # +1 for letters that match
my $MISMATCH  = -1; # -1 for letters that mismatch
my $GAP       = -1; # -1 for any gap

my $raw_out = $outroot . "alignment.raw";
my $btab_out = $outroot . "alignment.btab";
open(RAW,">$raw_out") || die "\nError: Cannot write to raw output file: $raw_out\n";
open(BTAB,">$btab_out") || die "\nError: Cannot write to btab output file: $btab_out\n";
foreach my $q (@Query) {
    my $seq1 = $QUERY{$q};
    foreach my $s (@Subject) {
	print RAW " Query:   $q\n Subject: $s\n\n";
	my $seq2 = $SUBJECT{$s};
	
	# initialization
	my @matrix;
	$matrix[0][0]{score}   = 0;
	$matrix[0][0]{pointer} = "none";
	for(my $j = 1; $j <= length($seq1); $j++) {
	    $matrix[0][$j]{score}   = 0;
	    $matrix[0][$j]{pointer} = "none";
	}
	for (my $i = 1; $i <= length($seq2); $i++) {
	    $matrix[$i][0]{score}   = 0;
	    $matrix[$i][0]{pointer} = "none";
	}
	# fill
	my $max_i     = 0;
	my $max_j     = 0;
	my $max_score = 0;

	for(my $i = 1; $i <= length($seq2); $i++) {
	    for(my $j = 1; $j <= length($seq1); $j++) {
		my ($diagonal_score, $left_score, $up_score);
		
		# calculate match score
		my $letter1 = substr($seq1, $j-1, 1);
		my $letter2 = substr($seq2, $i-1, 1);      
		if ($letter1 eq $letter2) {
		    $diagonal_score = $matrix[$i-1][$j-1]{score} + $MATCH;
		}
		else {
		    $diagonal_score = $matrix[$i-1][$j-1]{score} + $MISMATCH;
		}
		
		# calculate gap scores
		$up_score   = $matrix[$i-1][$j]{score} + $GAP;
		$left_score = $matrix[$i][$j-1]{score} + $GAP;
		
		if ($diagonal_score <= 0 and $up_score <= 0 and $left_score <= 0) {
		    $matrix[$i][$j]{score}   = 0;
		    $matrix[$i][$j]{pointer} = "none";
		    next; # terminate this iteration of the loop
		}
		
		
		# choose best score
		if ($diagonal_score >= $up_score) {
		    if ($diagonal_score >= $left_score) {
			$matrix[$i][$j]{score}   = $diagonal_score;
			$matrix[$i][$j]{pointer} = "diagonal";
		    }
		    else {
			$matrix[$i][$j]{score}   = $left_score;
			$matrix[$i][$j]{pointer} = "left";
		    }
		} else {
		    if ($up_score >= $left_score) {
			$matrix[$i][$j]{score}   = $up_score;
			$matrix[$i][$j]{pointer} = "up";
		    }
		    else {
			$matrix[$i][$j]{score}   = $left_score;
			$matrix[$i][$j]{pointer} = "left";
		    }
		}
		
		# set maximum score
		if ($matrix[$i][$j]{score} > $max_score) {
		    $max_i     = $i;
		    $max_j     = $j;
		    $max_score = $matrix[$i][$j]{score};
		}
	    }
	}
	
	# trace-back
	
	my $align1 = "";
	my $align2 = "";
	
	my $j = $max_j;
	my $i = $max_i;
	my $send = $i;
	my $qend = $j;
	
	while (1) {
	    last if $matrix[$i][$j]{pointer} eq "none";
	    
	    if ($matrix[$i][$j]{pointer} eq "diagonal") {
		$align1 .= substr($seq1, $j-1, 1);
		$align2 .= substr($seq2, $i-1, 1);
		$i--; $j--;
	    }
	    elsif ($matrix[$i][$j]{pointer} eq "left") {
		$align1 .= substr($seq1, $j-1, 1);
		$align2 .= "-";
		$j--;
	    }
	    elsif ($matrix[$i][$j]{pointer} eq "up") {
		$align1 .= "-";
		$align2 .= substr($seq2, $i-1, 1);
		$i--;
	    }  
	}
	my $sstart = $i + 1;
        my $qstart = $j + 1;
	$align1 = reverse $align1;
	$align2 = reverse $align2;
	my $aln_string;
	my @One = split(//, $align1);
	my @Two = split(//, $align2);
	my $match = 0;
	for(my $i=0;$i<length($align1);$i++) {
	    if ($One[$i] eq $Two[$i]) {
		$aln_string = $aln_string . "|";
		$match++;
	    }
	    else {
		$aln_string = $aln_string . " ";
	    }
	}
	my $percent_identity = $match / length($align1);
	$percent_identity *= 100;
	$percent_identity = Round($percent_identity, 2);
	my $mismatch = $aln_string =~ tr/ / /;
	my $gaps = $align1 =~ tr/-/-/;
	$gaps   += $align2 =~ tr/-/-/;
	$mismatch -= $gaps;
	## Printing to tabular output
	print BTAB $q . "\t" .
	    $s . "\t" . 
	    $percent_identity . "\t" . 
	    length($align1) . "\t" . 
	    $mismatch . "\t" . 
	    $gaps . "\t" .
	    $qstart . "\t" . 
	    $qend . "\t" . 
	    $sstart . "\t" .
	    $send . "\t" .
	    $max_score . "\n";
	
	## Printing to the raw outpuit
	unless (length($align1) > 80) {
	    print RAW "Query:   $align1\n";
	    print RAW "         $aln_string\n";
	    print RAW "Subject: $align2\n";
	    print RAW "\nIdentity: $percent_identity\n";
	    print RAW "Score: $max_score\n";
	}
	else {
	    my $fold = length($align1) / 80;
	    $fold = ceil($fold);
	    my @Aln = split(//, $aln_string);
	    print RAW "Query:   ";
	    for (my $i=0;$i<80;$i++) {
		print RAW $One[0];
		shift @One;
	    }
	    print RAW "\n         ";
	    for (my $i=0;$i<80;$i++) {
		print RAW $Aln[0];
		shift @Aln;
	    }
	    print RAW"\nSubject: ";
	    for (my $i=0;$i<80;$i++) {
		print RAW $Two[0];
		shift @Two;
	    }
	    print RAW "\n\n";
	    for(my $i=2;$i<$fold;$i++) {
		print RAW "         ";
		for (my $i=0;$i<80;$i++) {
		    print RAW $One[0];
		    shift @One;
		}
		print RAW"\n         ";
		for (my $i=0;$i<80;$i++) {
		    print RAW $Aln[0];
		    shift @Aln;
		}
		print RAW "\n         ";
		for (my $i=0;$i<80;$i++) {
		    print RAW $Two[0];
		    shift @Two;
		}
		print RAW "\n\n";
	    }
	    print RAW "         ";
	    for (my $i=0;$i<scalar(@One);$i++) {
		print RAW $One[0];
		shift@One;
	    }
	    print RAW "\n         ";
	    for (my $i=0;$i<scalar(@Aln);$i++) {
		print RAW $Aln[0];
		shift @Aln;
	    }
	    print RAW "\n         ";
	    for (my $i=0;$i<scalar(@Two);$i++) {
		print RAW $Two[0];
		shift @Two;
	    }
	    print RAW "\n\n";
	}
    }
}

close(RAW);
close(BTAB);

## Subroutines
sub ReadFasta
{
    my $infile = $_[0];
    my %Tmp;
    my ($header,$sequence);
    my $line_count = 0;
    open(IN,"<$infile") || die "\n Cannot open file: $infile\n";
    while(<IN>) {
	chomp;
	if ($line_count == 0) {
	    $header = $_;
            $header =~ s/^>//;
	}
	elsif ($_ =~ m/^>/) {
	    $Tmp{$header} = $sequence;
	    $sequence = "";
	    $header = $_;
	    $header =~ s/^>//;
	}
	else {
	    $sequence = $sequence . $_;
	}
	$line_count++;
    }
    close(IN);
    $Tmp{$header} = $sequence;
    return %Tmp;
}

sub ReadFastaHeader
{
    my $infile = $_[0];
    my @Tmp;
    open(IN,"<$infile") || die "\n Cannot open file: $infile\n";
    while(<IN>) {
	chomp;
	if ($_ =~ m/^>/) {
	    my $header = $_;
	    $header =~ s/^>//;
	    push(@Tmp, $header);
	}
    }
    close(IN);
    return(@Tmp);
}
sub Round
{       my $number = $_[0];
        my $digits = $_[1];
        $number = (floor(((10**$digits) * $number) + 0.5))/10**$digits;
        return $number;
}

exit 0;
