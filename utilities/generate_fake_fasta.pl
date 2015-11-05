#!/usr/bin/perl -w

# MANUAL FOR generate_fake_fasta.pl

=pod

=head1 NAME

generate_fake_fasta.pl -- makes a fake fasta of some size...

=head1 SYNOPSIS

 generate_fake_fasta.pl --out /Path/to/output.fasta --size=10
                     [--help] [--manual]

=head1 DESCRIPTION

 Makes a FASTA file of random nucleotides that will be however
 many megabytes you designate in "--size".
 
=head1 OPTIONS

=over 3

=item B<-s, --size>=NUMBER

Size you want FASTA file to be in megabytes. (Required) 

=item B<-o, --out>=FILENAME

Output file in FASTA format. (Required) 

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

Copyright 2015 Daniel Nasko.  
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
my($size,$outfile,$help,$manual);

GetOptions (	
				"s|size=s"	=>	\$size,
				"o|out=s"	=>	\$outfile,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --size not found.\n\n", -exitval => 2, -verbose => 1)  if (! $size );
pod2usage( -msg  => "\n\n ERROR!  Required argument --outfile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile);

my $id = 1;
my $chars = 0;

open(OUT,">$outfile") || die "\nError: Cannot write to the output file: $outfile\n\n";
while($chars < $size*1000000) {
    my $header = ">" . "sequence_" . $id . "\n";
    my $seq = rand_seq() . "\n";
    print OUT $header;
    print OUT $seq;
    $chars += length($header) + length($seq);
    $id++;
}
close(OUT);

sub rand_seq
{
    my $range = 200;
    my $minimum = 200;
    my $random_number = int(rand($range)) + $minimum;
    my %bases = ( 0 => 'A', 1 => 'T',
	2 => 'G', 3 => 'C' );
    my $s = "";
    for (my $i=0; $i<$random_number; $i++) {
	$s = $s . $bases{int(rand(3))};
    }
    return $s;
}
   

exit 0;
