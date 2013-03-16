#!/usr/bin/perl -w

# MANUAL FOR string_alignment.pl

=pod

=head1 NAME

string_alignment.pl -- aligns two protein strings using dynamic programming

=head1 SYNOPSIS

 string_alignment.pl --short AQQWVGTA --long WSRLNTAAGTQC
                     [--help] [--manual]

=head1 DESCRIPTION

Takes in two strings of proteins (one long, one short) and begins to
align the two of them using dynamic programming. Coe adopted from
O'Reily's Mastering Perl for Bioinformatics (c) 2003
 
=head1 OPTIONS

=over 3

=item B<-s, --short>=FILENAME

Input shorter sequence. (Required) 

=item B<-l, --long>=FILENAME

Input longer sequence. (Required) 

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries.



=head1 AUTHOR

Written by Daniel Nasko, 
Center for Bioinformatics and Computational Biology, University of Delaware.

=head1 REPORTING BUGS

Report bugs to dnasko@udel.edu

=head1 COPYRIGHT

Copyright 2012 Daniel Nasko.  
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

#ARGUMENTS WITH NO DEFAULT
my($short,$long,$help,$manual);

GetOptions (	
				"s|in=s"	=>	\$short,
				"l|out=s"	=>	\$long,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage(-verbose => 1)  if ($help);
pod2usage( -msg  => "ERROR!  Required arguments -s and/or -l not found.\n", -exitval => 2, -verbose => 1)  if (! $short || ! $long);

print "PATTERN:\n$short\n";
print "TEXT:\n$long\n";

my $SLEN = length $short;
my $LLEN = length $long;

## D is the Distance matrix, which shows the "edit distance" between
## substrings of the pattern and the text.
## It is implemented as a reference to an anonymous array.
my $D = [];

## The rows corresponding to the longer text
## Initialize row 0 of D.
for (my $t=0; $t <= $LLEN ; ++$t) {
    $D->[$t][0] = 0;
}

## The columns corresponding to the shorter pattern
## Initialize column 0 of D
for (my $p=0; $p <= $SLEN ; ++$p) {
    $D->[0][$p] = $p;
}

## Compute the edit distances.
for (my $t=1; $t <= $LLEN ; ++$t) {
    for (my $p=1; $p <= $SLEN ; ++$p) {
	
	$D->[$t][$p] =
	
	## Choose whichever of the three alternatives has the leat cost
	min3(
	    ## First alternative
	    ## The text and the pattern may or may not match at this charecter . . .
	    substr($long, $t-1, 1) eq substr($short, $p-1, 1)
	    ? $D->[$t-1][$p-1]	## If they match, no increase in edit distance !
	    :	$D->[$t-1][$p-1] + 1,
	    
	    ## Second alternatice.
	    ## If the text is missing a charecter
	    $D->[$t-1][$p] + 1,
	    
	    ## Third alternative
	    ## If the pattern is missing a charecter
	    $D->[$t][$p-1] + 1
	)
    }
}

## Print D, the resulting edit distance array
for (my $p=0; $p <= $SLEN ; ++$p) {
    for (my $t=0; $t <= $LLEN ; ++$t) {
	print $D->[$t][$p], " ";
    }
    print "\n";
}

my @matches = ();
my $bestscore = 10000000;

## Find the best match(es).
## The edit distance in the last row.
for (my $t=1; $t <= $LLEN ; ++$t) {
    if ($D->[$t][$SLEN] < $bestscore) {
	$bestscore = $D->[$t][$SLEN];
	@matches = ($t);
    }
    elsif ( $D->[$t][$SLEN] == $bestscore) {
	push(@matches, $t);
    }
}

## Report the best match(es).
print "\nThe best match for the pattern $short\n";
print "has an edit distance of $bestscore\n";
print "and appears in the text ending at location";
print "s" if ( @matches > 1);
print " @matches\n";

sub min3
{
    my ($i, $j, $k) = @_;
    my($tmp);
    
    $tmp = ($i < $j ? $i : $j);
    $tmp < $k ? $tmp : $k;
}


