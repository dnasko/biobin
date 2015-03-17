#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;

unless (@ARGV) {
    die "\n USAGE:\n \$ format_fasta.pl input.fasta output.fasta\n\n";
}
my $infile = $ARGV[0];
my $outfile = $ARGV[1];

my ($seqio_obj,$seq_obj);
my $seqout = Bio::SeqIO->new(-file => ">$outfile", '-format' => 'Fasta');
$seqio_obj = Bio::SeqIO->new(-file => "$infile", -format => "fasta" ) or die $!;
while ($seq_obj = $seqio_obj->next_seq){
    my $header = $seq_obj->display_id;
    my $forward = $seq_obj->seq;
    $seqout->write_seq($seq_obj);
}

exit 0;

