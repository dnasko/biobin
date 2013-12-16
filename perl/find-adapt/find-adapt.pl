#!/usr/bin/perl -w

# MANUAL FOR find-adapt.pl

=pod

=head1 NAME

find-adapt.pl -- find sequences that have certain adapter / barcode / primer

=head1 SYNOPSIS

 find-adapt.pl --fasta=/path/to/file.fasta --adapter=ATGCGTACGTAGTG --window=30 --identity=100 --outfile=/path/to/outfile.fasta
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

=item B<-a, --adapter>=STRING

The adapter your searching for. (Required)

=item B<-w, --window>=INTEGER

How many bases into the sequence would you like to search? (Default=30)

=item B<-i, --identity=INTEGER

What percent similarity must the input adapter match the putative
adapter in the sequence. (Default = 100)

=item B<-o, --outfile>=FILENAME

Location and name of outfile. (Required)

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries.

Bio::Seq
Bio::SeqIO
String::Approx

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
use FindBin;
use Cwd 'abs_path';
use lib abs_path("$FindBin::Bin/lib/lib64/perl5");
use lib abs_path("$FindBin::Bin/lib/");
use Bio::SeqIO;
use String::Approx 'amatch';

## ARGUMENTS WITH NO DEFAULT
my($fasta,$adapter,$outfile,$barcode,$help,$manual);
## ARGUMENTS WITH DEFAULTS
my $identity = 100;
my $window = 30;
my $forw = 0;
my $rev = 0;
my $total = 0;

GetOptions (	
                    "f|fasta=s"	        =>	\$fasta,
                    "a|adapter=s"	=>	\$adapter,
                    "w|window=i"          =>      \$window,
                    "i|identity=i"      =>       \$identity,
                    "o|outfile=s"         =>      \$outfile,
                    "h|help"	        =>	\$help,
                    "m|manual"	        =>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage(-verbose => 1)  if ($help);
pod2usage( -msg  => "\n\nERROR: Required arguments --fasta not found\n\n", -exitval => 2, -verbose => 1)  if (! $fasta);
pod2usage( -msg  => "\n\nERROR: Required arguments --adapter not found\n\n", -exitval => 2, -verbose => 1)  if (! $adapter);
pod2usage( -msg  => "\n\nERROR: Required arguments --outfile not found\n\n", -exitval => 2, -verbose => 1)  if (! $outfile);
pod2usage( -msg  => "\n\nERROR: --identity must be a whole number between 0 and 100\n\n", -exitval => 2, -verbose => 1)  if ( $identity > 100 || $identity < 0);
my $identity_string = $identity;
$identity_string = 100 - $identity_string;
$identity_string = $identity_string . "%";
open(OUT,">$outfile") || die "\n\n Cannot open the outfile $outfile\n\n";
my ($seqio_obj,$seq_obj,%NT_COUNT);
$seqio_obj = Bio::SeqIO->new(-file => "$fasta", -format => "fasta" ) or die $!;
while ($seq_obj = $seqio_obj->next_seq){ 
    my $position = 0;
    my $header = $seq_obj->display_id;
    my $forward = $seq_obj->seq;
    my $revcom = $seq_obj->revcom;
    my $reverse = $revcom->seq;
    my $top_forw = substr $forward, 0, $window;
    my $top_rev = substr $reverse, 0, $window;
    if (amatch ($adapter,[ $identity_string ], $top_forw)) {
        print OUT ">$header\n$forward\n";
        $forw++;
    }
    elsif (amatch ($adapter,[ $identity_string ], $top_rev)) {
        print OUT ">$header\n$reverse\n";           ## So if you match the primer on the reverse compliment,  print out the sequence in that orientation.
        $rev++;
    }
    $total++;
}
close(OUT);
my $find = $rev + $forw;
my $percent = $find/$total;
$percent *= 100;
print "\n\n You searched for adapter in the first/last $window bases\n At $identity percent similarity\n You found adapters in $percent percent of the input sequences\n $forw were in the forward orientation\n $rev were in the RC orientation\n Output written to $outfile\n\n";








