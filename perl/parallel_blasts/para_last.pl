#!/usr/bin/perl -w

# MANUAL FOR para_last.pl

=pod

=head1 NAME

para_last.pl -- embarasingly parallel LAST

=head1 SYNOPSIS

 para_last.pl -query /path/to/infile.fasta -db /path/to/db -out /path/to/output.maf -e 131 -outfmt 1 -threads 1 -m 100 -F 15 -p BL80
                     [--help] [--manual]

=head1 DESCRIPTION

=head1 OPTIONS

=over 3

=item B<-q, --query>=FILENAME

Input query file in FASTA format. (Required) 

=item B<-d, --d>=FILENAME

Input subject DB. (Required)

=item B<-o, --out>=FILENAME

Path to output btab file. (Required)

=item B<-e, --score>=INT

E-value. (Default = 131)

=item B<-f, --outfmt>=INT

Output format. (Default = 1)

=item B<-t, --threads>=INT

Number of CPUs to use. (Default = 1)

=item B<-m, --max>=INT

maximum initial matches per query position. (Default = 10)

=item B<-F, --frameshift>=INT

Frameshift cost. (Deafult = 15)

=item B<-p, --matrix>=INT

Protein substitutiton matrix. (Default=BL62)

=item B<-h, --help>

Displays the usage message.  (Optional) 

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
use threads;
use FindBin;
use Cwd 'abs_path';
my $script_working_dir = $FindBin::Bin;

#ARGUMENTS WITH NO DEFAULT
my($query,$db,$out,$help);

## With Defaults
my $threads = 1;
my $score = 131;
my $outfmt = 1;
my $m = 10;
my $frameshift = 15;
my $matrix = "BL62";
my @THREADS;

GetOptions (	
				"q|query=s"	=>	\$query,
                                "d|db=s"        =>      \$db,
                                "o|out=s"       =>      \$out,
                                "e|score=s"     =>      \$score,
                                "f|outfmt=s"    =>      \$outfmt,
                                "t|threads=i"   =>      \$threads,
                                "m|max=i"       =>      \$m,
                                "r|frameshift=i" =>     \$frameshift,
                                "p|matrix=s"    =>      \$matrix,
                                "h|help"	=>	\$help);

# VALIDATE ARGS
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required arguments --query not found.\n\n", -exitval => 2, -verbose => 1)  if (! $query );
pod2usage( -msg  => "\n\n ERROR!  Required arguments --db not found.\n\n", -exitval => 2, -verbose => 1)  if (! $db );
pod2usage( -msg  => "\n\n ERROR!  Required arguments --out not found.\n\n", -exitval => 2, -verbose => 1)  if (! $out );

my $program = "lastal";
my @chars = ("A".."Z", "a".."z");
my $rand_string;
$rand_string .= $chars[rand @chars] for 1..8;
my $tmp_file = "./$program" . "_tmp_" . $rand_string;

## Check that blastn and makeblastdb are installed on this machine
my $PROG = `which $program`; unless ($PROG =~ m/$program/) { die "\n\n ERROR: External dependency '$program' not installed in system PATH\n\n";}
my $date = `date`;
print STDERR " Using $threads threads\n";
print STDERR " Using this BLAST: $PROG Beginning: $date\n";
print STDERR "
 m = $m
 F = $frameshift
 e = $score
 p = $matrix\n
";

## All clear, time to set up some globals
my $seqs = `egrep -c "^>" $query`;
chomp($seqs);

## Create the working directory, then make blastdb and execute blastn
if ($threads == 1) {
    print `$program -F $frameshift -e $score -p $matrix -m $m -o $out $db $query`;
}
else {
    print `mkdir -p $tmp_file`;
    print `chmod 700 $tmp_file`;
    my $seqs_per_file = $seqs / $threads;
    if ($seqs_per_file =~ m/\./) {
	$seqs_per_file =~ s/\..*//;
	$seqs_per_file++;
    }
    print `perl $script_working_dir/bin/splitFASTA.pl $query $tmp_file split $seqs_per_file`;
    print `mkdir -p $tmp_file/btab_splits`;
    for (my $i=1; $i<=$threads; $i++) {
	my $blast_exe = "$program -F $frameshift -e $score -p $matrix -m $m -o $tmp_file/btab_splits/split.$i.maf $db $tmp_file/split-$i.fsa";
	push (@THREADS, threads->create('task',"$blast_exe"));
    }
    foreach my $thread (@THREADS) {
	$thread->join();
    }
    print `cat $tmp_file/btab_splits/* > $out`;
    print `rm -rf $tmp_file`;
}
$date = `date`;
print STDERR "\n LAST complete: $date\n";

sub task
{
    system( @_ );
}

exit 0;
