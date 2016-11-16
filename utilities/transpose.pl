#!/usr/bin/perl -w

# MANUAL FOR transpose.pl

=pod

=head1 NAME

transpose.pl -- will transpose a file

=head1 SYNOPSIS

 transpose.pl --in=/Path/to/infile.txt --out=/Path/to/output.txt
                     [--csv] [--help] [--manual]

=head1 DESCRIPTION

 Will transpose a file in tab-delimmited or csv form.
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in tab-delimmited format. (Required) 

=item B<-o, --out>=FILENAME

Output file in tab-delimmited format. (Required) 

=item B<-c, --csv>

Indicates that the file is in CSV formate. (Default is that file is TSV)

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

Copyright 2016 Daniel Nasko.  
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
my($infile,$outfile,$csv,$help,$manual);

GetOptions (	
				"i|in=s"	=>	\$infile,
				"o|out=s"	=>	\$outfile,
				"c|csv"         =>      \$csv,
                                "h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument -infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );
pod2usage( -msg  => "\n\n ERROR!  Required argument -outfile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile);

if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}

my @Matrix;

my $i=0;
my $jmax=0;

open(IN,"<$infile") || die "\n Cannot open the file: $infile\n";
while(<IN>) {
    chomp;
    my @a;
    if ($csv) {
	@a = split(/,/, $_);
    }
    else {
	@a = split(/\t/, $_);
    }
    if (scalar(@a) > $jmax) { $jmax = scalar(@a); }
    for (my $j=0; $j<scalar(@a); $j++) {
	$Matrix[$i][$j] = $a[$j];
    }
    $i++;
}
close(IN);

open(OUT,">$outfile") || die "\n Cannot write to: $outfile\n";
for (my $J=0; $J<$jmax; $J++) {
    my @b;
    for (my $I=0; $I<$i; $I++) {
	push(@b, $Matrix[$I][$J]);
    }
    if ($csv) {
	print OUT join(",", @b) . "\n";
    }
    else {
	print OUT join("\t", @b) . "\n";
    }
}
close(OUT);

exit 0;
