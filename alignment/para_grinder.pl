#!/usr/bin/perl -w

# MANUAL FOR para_grinder.pl

=pod

=head1 NAME

para_grinder.pl -- embarasingly parallel grinder

=head1 SYNOPSIS

 para_grinder.pl --input /Path/to/infile.fasta --outdir /Path/to/outdir --base output_base --num_read_pairs 10000 --threads 12
                     [--help] [--manual]

=head1 DESCRIPTION

=head1 OPTIONS

=over 3

=item B<-i, --input>=FILENAME

Input file in FASTA format. (Required) 

=item B<-o, --outdir>=DIR

Output directory. (Required)

=item B<-b, --base>=NAME

Base name of output file. (Required)

=item B<-n, --num_read_pairs>=INT

Number of read pairs for Grinder to make. (Required)

=item B<-t, --threads>=INT

Number of CPUs to use. (Default = 1)

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
use threads;
use FindBin;
use Cwd 'abs_path';
my $script_working_dir = $FindBin::Bin;

#ARGUMENTS WITH NO DEFAULT
my($infile,$outdir,$base,$num_read_pairs,$help,$manual);
my $threads = 1;
my @THREADS;

GetOptions (	
				"i|infile=s"	     =>	\$infile,
                                "o|outdir=s"         => \$outdir,
                                "b|base=s"           => \$base,
                                "n|num_read_pairs=i" => \$num_read_pairs,
                                "t|threads=i"        => \$threads,
             			"h|help"	     =>	\$help,
				"m|manual"	     =>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );
pod2usage( -msg  => "\n\n ERROR!  Required argument --outdir not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outdir );
pod2usage( -msg  => "\n\n ERROR!  Required argument --base not found.\n\n", -exitval => 2, -verbose => 1)  if (! $base );
pod2usage( -msg  => "\n\n ERROR!  Required argument --num_read_pairs not found.\n\n", -exitval => 2, -verbose => 1)  if (! $num_read_pairs );
my $program = "grinder";
my @chars = ("A".."Z", "a".."z");
my $rand_string;
$rand_string .= $chars[rand @chars] for 1..8;
my $tmp_file = "./$program" . "_tmp_" . $rand_string;

## Check that Grinder is installed on this machine
my $PROG = `which $program`; unless ($PROG =~ m/$program/) { die "\n\n ERROR: External dependency '$program' not installed in system PATH\n\n";}
my $date = `date`;
print STDERR " Using $threads threads\n";
print STDERR " Using this $program: $PROG Beginning: $date\n";

## Oh, grinder wants number of reads, not read pairs, so we
##  double the number of reads.
$num_read_pairs *= 2;

## All good, let's roll...
my ($qgood,$qbad) = (39,10);
## Create the working directory
if ($threads == 1) {
    print `$program -fastq_output 1 -qual_levels $qgood $qbad -pf $script_working_dir/para_blast_bin/paired_end_150_illumina.grinder.spec -od $outdir -total_reads $num_read_pairs -bn $base -rf $infile`;
}
else {
    print `mkdir -p $tmp_file`;
    print `chmod 700 $tmp_file`;
    my $seqs_per_file = $num_read_pairs / $threads;
    $seqs_per_file = ceil($seqs_per_file);
    for (my $i=1; $i<=$threads; $i++) {
	print `mkdir $tmp_file/$i`;
	my $grinder_exe = "$program -fastq_output 1 -qual_levels $qgood $qbad -pf $script_working_dir/para_blast_bin/paired_end_150_illumina.grinder.spec -od $tmp_file/$i -total_reads $seqs_per_file -bn $base -rf $infile > $tmp_file/$i/std.out 2> $tmp_file/$i/std.err";
	push (@THREADS, threads->create('task',"$grinder_exe"));
    }
    foreach my $thread (@THREADS) {
	$thread->join();
    }
    # print `cat $tmp_file/btab_splits/* > $out`;
    # print `rm -rf $tmp_file`;
}
$date = `date`;
print STDERR "\n Grinder complete: $date\n";

sub task
{
    system( @_ );
}

exit 0;
