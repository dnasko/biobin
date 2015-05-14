#!/usr/bin/perl -w

# MANUAL FOR pick_random_seqs_without_replacement.pl

=pod

=head1 NAME

 pick_random_seqs_without_replacement.pl -- does what the name suggests

=head1 SYNOPSIS

 pick_random_seqs_without_replacement.pl --fasta=/Path/to/infile.fasta --out=/Path/to/output.fasta --samples=100
                     [--help] [--manual]

=head1 DESCRIPTION

 Picks rnadom sequences from a FASTA file (WITHOUT replacement) and prints them to your
 output FASTA file.
 
=head1 OPTIONS

=over 3

=item B<-f, --fasta>=FILENAME

Input file in FASTA format. (Required) 

=item B<-o, --out>=FILENAME

Output file in FASTA format. (Required) 

=item B<-s, --samples>=INT

Number of samples to take. (Required)
Must be less than the number of sequences.

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
use Bio::SeqIO;

#ARGUMENTS WITH NO DEFAULT
my($fasta,$out,$samples,$help,$manual);

GetOptions (	
				"f|fasta=s"	=>	\$fasta,
				"o|out=s"	=>	\$out,
				"s|samples=i"   =>      \$samples,
                                "h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --fasta not found.\n\n",   -exitval => 2, -verbose => 1)  if (! $fasta );
pod2usage( -msg  => "\n\n ERROR!  Required argument --out not found.\n\n",     -exitval => 2, -verbose => 1)  if (! $out );
pod2usage( -msg  => "\n\n ERROR!  Required argument --samples not found.\n\n", -exitval => 2, -verbose => 1)  if (! $samples );

my $nseqs = `grep -c "^>" $fasta`; chomp($nseqs);
if ( $samples > $nseqs ) { die " The number of samples you want to take exceeds the number of sequences that there are to sample from:\n Seqs = $nseqs\n Desired samples = $samples\n\n"; }

my %Random = generate_random_hash($samples);
my $count = 1;
my $printing_count = 1;

my $seq_in  = Bio::SeqIO->new(
    -format => 'fasta',
    -file   => $fasta );
open(OUT, ">$out") || die "\n Cannot write to: $out\n\n";
while( my $seq = $seq_in->next_seq() ) {
    if (exists $Random{$count}) {
	for (my $i=1; $i <= $Random{$count}; $i++) {
	    print OUT ">" . $printing_count . "_" . $seq->id . "\n";
	    print OUT $seq->seq . "\n";
	    $printing_count++;
	}
    }
    $count++;
}
close(OUT);

sub generate_random_hash
{
    my $n = $_[0];
    my %h;
    while(keys (%h) < $n) {
	my $num = int(rand($nseqs-1))+1;
	$h{$num} = 1;
    }
    # for ( my $i=0; $i<$n; $i++ ) {
    # 	my $num = int(rand($nseqs-1))+1;
    # 	$h{$num}++;
    # }
    return %h;
}

exit 0;
