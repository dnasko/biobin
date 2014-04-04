#!/usr/bin/perl -w

# MANUAL FOR find_adapt_batches.pl

=pod

=head1 NAME

find_adapt_batches.pl -- find sequences that have certain adapter / barcode / primer

=head1 SYNOPSIS

 find_adapt_batches.pl --adapters=/Path/to/adapters.lookup --fasta=/path/to/file.fasta --window=30 --identity=100 --outdir=/path/to/outfile.fasta
                     [--help] [--manual]

=head1 DESCRIPTION

Checks first --window bases for the adapter.
Then checks last --window bases for RC of adapter.
If you find the adapter then print it to the outfile.
Search for the adapter at --identity similarity. So in
 the above example, we are searching for the adapter
at 100% similarity (100)
 
=head1 OPTIONS

=over 3

=item B<-f, --fasta>=FILENAME

Input file in FASTA format. (Required)

=item B<-a, --adapter>=FILENAME

The adapters your searching for. Tab and line delimmited (Required)

=item B<-w, --window>=INTEGER

How many bases into the sequence would you like to search? (Default=30)

=item B<-i, --identity=INTEGER

What percent similarity must the input adapter match the putative
adapter in the sequence. (Default = 100)

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries.

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

## ARGUMENTS WITH NO DEFAULT
my($fasta,$adapter,$outfile,$barcode,$help,$manual);
## ARGUMENTS WITH DEFAULTS
my $identity = 100;
my $window = 30;

GetOptions (	
                    "f|fasta=s"	        =>	\$fasta,
                    "a|adapter=s"	=>	\$adapter,
                    "w|window=i"        =>      \$window,
                    "i|identity=i"      =>      \$identity,
                    "h|help"	        =>	\$help,
                    "m|manual"	        =>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage(-verbose => 1)  if ($help);
pod2usage( -msg  => "\n\nERROR: Required arguments --fasta not found\n\n", -exitval => 2, -verbose => 1)  if (! $fasta);
pod2usage( -msg  => "\n\nERROR: Required arguments --adapter not found\n\n", -exitval => 2, -verbose => 1)  if (! $adapter);
pod2usage( -msg  => "\n\nERROR: --identity must be a whole number between 0 and 100\n\n", -exitval => 2, -verbose => 1)  if ( $identity > 100 || $identity < 0);
my $identity_string = $identity;
$identity_string = 100 - $identity_string;
$identity_string = $identity_string . "%";

print `mkdir find_adapt_out`;
print `mkdir find_adapt_out/$identity`;

my %Adapters;
my @Adapt;
open(IN,"<$adapter") || die "\n\n Cannot open adapter lookup file: $adapter\n\n";
while(<IN>) {
    chomp;
    my @A = split(/\t/, $_);
    $Adapters{$A[0]} = $A[1];
    push(@Adapt, $A[0]);
}
close(IN);

for (my $i=0; $i < scalar(@Adapt); $i++) {
    my $forw = 0;
    my $rev = 0;
    my $total = 0;
    if ($i == 0) {
	if ($fasta =~ m/\.gz$/) {
	    open(IN,"gunzip -c $fasta |") || die "\n\n Cannot open the input file: $fasta\n\n";
	}
	else {
	    open(IN,"<$fasta") || die "\n\n Cannot open the input file: $fasta\n\n";
	}
	my $outroot = $Adapt[$i] . "." . $identity;
	open(OUT,">$outroot.fasta") || die "\n\n Cannot open outfile: $outroot.fasta\n\n";
	open(OUTN,">$outroot.nil") || die "\n\n Cannot open outfile: $outroot.nil\n\n";
	my $header;
	my $forward;
	my $n_seqs = 0;
	$adapter = $Adapters{$Adapt[$i]};
	while(<IN>) {
	    chomp;
	    if ($_ =~ m/^>/) {
		unless ($n_seqs == 0) {
		    my $position = 0;
		    my $revcom = scalar reverse $forward;
		    $revcom =~ tr/ATGCatgc/TACGtacg/;
		    my $top_forw = substr $forward, 0, $window;
		    my $top_rev = substr $revcom, 0, $window;
		    if (amatch ($adapter,[ $identity_string ], $top_forw)) {
			print OUT "$header\n$forward\n";
			$forw++;
		    }
		    elsif (amatch ($adapter,[ $identity_string ], $top_rev)) {
			print OUT "$header\n$revcom\n";           ## So if you match the primer on the reverse compliment,  print out the sequence in that orientation.
			$rev++;
		    }
		    else {
			print OUTN "$header\n$forward\n";
		    }
		    $total++;
		}
		$header = $_;
		$forward = '';
		$n_seqs++;
	    }
	    else {
		$forward = $forward . $_;
	    }
	}
	close(OUTN);
	close(OUT);
	close(IN);
	print `mv $outroot.fasta find_adapt_out/$identity/`;
	my $find = $rev + $forw;
	my $percent = $find/$total;
	$percent *= 100;
	my $fr = $rev + $forw;
	print "\n\n You searched for adapter in the first/last $window bases At $identity percent similarity\n You found adapters in $percent percent of the input sequences\n $forw were in the forward orientation\n $rev were in the RC orientation\n $fr were found\n Output written to: find_adapt_out/$identity/$outroot.fasta\n\n";
    }
    else {
	open(IN,"<$Adapt[$i-1].$identity.nil") || die "\n\n Cannot open the input file: $Adapt[$i-1].$identity.nil\n\n";
	my $outroot = $Adapt[$i] . "." . $identity;
        open(OUT,">$outroot.fasta") || die "\n\n Cannot open outfile: $outroot.fasta\n\n";
        open(OUTN,">$outroot.nil") || die "\n\n Cannot open outfile: $outroot.nil\n\n";
        my $header;
        my $forward;
        my $n_seqs = 0;
	$adapter = $Adapters{$Adapt[$i]};
	while(<IN>) {
	    chomp;
            if ($_ =~ m/^>/) {
                unless ($n_seqs == 0) {
                    my $position = 0;
                    my $revcom = scalar reverse $forward;
                    $revcom =~ tr/ATGCatgc/TACGtacg/;
                    my $top_forw = substr $forward, 0, $window;
                    my $top_rev = substr $revcom, 0, $window;
                    if (amatch ($adapter,[ $identity_string ], $top_forw)) {
                        print OUT "$header\n$forward\n";
                        $forw++;
                    }
                    elsif (amatch ($adapter,[ $identity_string ], $top_rev)) {
                        print OUT "$header\n$revcom\n";           ## So if you match the primer on the reverse compliment,  print out the sequence in that orientation.                                                                                                         
                        $rev++;
                    }
                    else {
                        print OUTN "$header\n$forward\n";
                    }
                    $total++;
                }
                $header = $_;
                $forward = '';
                $n_seqs++;
            }
            else {
                $forward = $forward . $_;
            }
	}
	close(IN);
	close(OUTN);
        close(OUT);
        print `mv $outroot.fasta find_adapt_out/$identity/`;
	my $find = $rev + $forw;
	my $percent = $find/$total;
	$percent *= 100;
	my $fr = $rev + $forw;
	print "\n\n You searched for adapter in the first/last $window bases
 At $identity percent similarity
 You found adapters in $percent percent of the input sequences
 $forw were in the forward orientation
 $rev were in the RC orientation
 $fr were found
 Output written to: find_adapt_out/$identity/$outroot.fasta\n\n";	
    }
}

exit 0;






