#!/usr/bin/perl -w

# MANUAL FOR btab_trim.pl

=pod

=head1 NAME

btab_trim.pl -- pull the top n hits from a btab file

=head1 SYNOPSIS

 btab_trim.pl --input /path/to/file.btab --hits 10 --out out.btab
                     [--help] [--manual]

=head1 DESCRIPTION

Runs through a BTAB file and keeps the top --hits blast hits and writes
these to the --out output file.

=head1 OPTIONS

=over 3

=item B<-i, --input>=FILENAME

Input file in tabular BLAST format. (Required) 

=item B<-n, --hits>=INTEGER

Top number of BLAST hits to keep. (Default=1)

=item B<-o, --out>=FILENAME

Output file in BTAB format. (Required)

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
my($input,$out,$help,$manual);

#ARGUMENTS WITH DEFAULT
my $hits = 1;

GetOptions (	
				"i|input=s"	=>	\$input,
				"n|hits=i"	=>	\$hits,
                                "o|out=s"       =>      \$out,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage(-verbose => 1)  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required arguments --input missing or not found.\n", -exitval => 2, -verbose => 1)  if (! $input );
pod2usage( -msg  => "\n\n ERROR!  Required arguments --out missing or not found.\n", -exitval => 2, -verbose => 1)  if (! $out );

my $prev;
my $count=0;
open(OUT,">$out") || die "\n Cannot open the output file: $out\n";
open(IN,"<$input") || die "\n Cannot open the fiel: $input\n";
while(<IN>) {
    chomp;
    my @a = split(/\t/, $_);
    if ($prev) {
	if ($prev eq $a[0]) {
	    if ($count < $hits) {
		print OUT $_ . "\n";
	    }
	}
	else {
	    print OUT $_ . "\n";
	    $count = 0;
	}
    }
    else {
	print OUT $_ . "\n";
    }
    $count++;
    $prev = $a[0];
}
close(IN);
close(OUT);

exit 0;



