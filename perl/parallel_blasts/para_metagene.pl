#!/usr/bin/perl -w
use strict;
use threads;
use FindBin;
use Cwd 'abs_path';
my $script_working_dir = $FindBin::Bin;

my $infile = $ARGV[0];
my $threads = $ARGV[1];
my $out = $ARGV[2];

my @THREADS1;
my @THREADS2;
my $program = "mga_linux_ia64";
my @chars = ("A".."Z", "a".."z");
my $rand_string;
$rand_string .= $chars[rand @chars] for 1..8;
my $tmp_file = "./$program" . "_tmp_" . $rand_string;
my $seqs = `egrep -c "^>" $infile`;
chomp($seqs);
my $seqs_per_file = $seqs / $threads;
if ($seqs_per_file =~ m/\./) {
    $seqs_per_file =~ s/\..*//;
    $seqs_per_file++;
}
print `mkdir -p $tmp_file`;
print `mkdir -p $tmp_file/mga`;
print `mkdir -p $tmp_file/fasta`;
print `mkdir -p $tmp_file/orf`;
print `perl $script_working_dir/para_blast_bin/splitFASTA.pl $infile $tmp_file split $seqs_per_file`;
print `mv $tmp_file/*.fsa $tmp_file/fasta`;

for (my $i=1; $i<=$threads; $i++) {
    my $mga_exe = "$program -m $tmp_file/fasta/split-$i.fsa > $tmp_file/mga/split.$i.mga";
    push (@THREADS1, threads->create('task',"$mga_exe"));
}
foreach my $thread (@THREADS1) {
    $thread->join();
}
# for (my $i=1; $i<=$threads; $i++) {
#     my $conv_exe = "perl /home/dnasko/scripts/perl/file_conversion/mga2seq_pep.pl --input=$tmp_file/fasta/split-$i.fsa --mga=$tmp_file/mga/split.$i.mga --prefix=out-$i --outdir=$tmp_file/orf";
#     push (@THREADS2, threads->create('task',"$conv_exe"));
# }
# foreach my $thread (@THREADS2) {
#     $thread->join();
# }
# print `cat $tmp_file/orf/* > $out`;
# # print `rm -rf $tmp_file`;

sub task
{
    system( @_ );
}

exit 0;
