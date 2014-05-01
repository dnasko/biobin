#!/usr/bin/perl -w

# MANUAL FOR base_counter.pl

=pod

=head1 NAME

base_counter.pl -- counts the number of bases in a FASTA or FASTQ file

=head1 SYNOPSIS

 base_counter.pl -in /Path/to/infile.fasta/q
                     [--help] [--manual]

=head1 DESCRIPTION

 Counts the number of bases in a FASTA or FASTQ file. Prints results to STDOUT
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in FASTA or FASTQ format. (Required) 

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

#ARGUMENTS WITH NO DEFAULT
my($infile,$help,$manual);

GetOptions (	
				"i|in=s"	=>	\$infile,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument -infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );

my $l = 0;
my $bases = 0;
my $first_line;
my %Bases;

if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
    $first_line = <IN>;
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
    $first_line = <IN>;
}
chomp($first_line);
if ($first_line =~ m/^>/) {
    while(<IN>) {
	chomp;
	unless ($_ =~ m/^>/) {
	    my $seq = $_;
	    my @Bases = split(//, $seq);
	    foreach my $base (@Bases) {
		$Bases{$base}++;
	    }
	    $bases += length($_);
	}
    }
}
elsif ($first_line =~ m/^@/) {
    if ($l == 1) {
	my $seq = $_;
	my @Bases =split(//, $seq);
	foreach my $base (@Bases) {
	    $Bases{$base}++;
	}
	$bases += length($_);
    }
    $l++;
    if ($l == 4) { $l = 0; }
}
else {
    close(IN);
    die "\n\n Error: Cannot detect what format the file is in.\n\n";
}
close(IN);

foreach my $base (sort keys %Bases) {
    my $percent = $Bases{$base} / $bases;
    print "$base\t$Bases{$base}\t$percent\n";
}

exit 0;
