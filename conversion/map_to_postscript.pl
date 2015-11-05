#!/usr/bin/perl -w

# MANUAL FOR map_to_postscript.pl

=pod

=head1 NAME

map_to_postscript.pl -- put the fasta headers back in the postscript image

=head1 SYNOPSIS

 map_to_postscript.pl -in /Path/to/infile.ps -map /Path/to/input.map -out /Path/to/output.ps
                     [--help] [--manual]

=head1 DESCRIPTION

 Puts the FASTA headers back in the postscript file.
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in post script format. (Required) 

=item B<-m, --map>=FILENAME

Input file in map format. (Required)

=item B<-o, --out>=FILENAME

Output file in post script format. (Required) 

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-n, --manual>

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
my($infile,$map,$outfile,$help,$manual);

GetOptions (	
				"i|in=s"	=>	\$infile,
                                "m|map=s"       =>      \$map,
                                "o|out=s"	=>	\$outfile,
				"h|help"	=>	\$help,
				"n|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument -infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );
pod2usage( -msg  => "\n\n ERROR!  Required argument -outfile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile);
pod2usage( -msg  => "\n\n ERROR!  Required argument -map not found.\n\n", -exitval => 2, -verbose => 1)  if (! $map);

my %Map;

if ($map =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $map |") || die "\n\n Cannot open the map file: $map\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$map") || die "\n\n Cannot open the map file: $map\n\n";
}
while(<IN>) {
    chomp;
    my @A = split(/\t/, $_);
    $Map{$A[0]} = $A[1];
}
close(IN);

open(OUT,">$outfile");
open(IN,"<$infile");
while(<IN>) {
    chomp;
    if ($_ =~ m/^\(/) {
	my $id = $_;
	$id =~ s/^\(//;
	$id =~ s/\).*//;
	if (exists $Map{$id}) {
	    my $label = "(" . $Map{$id} . ") show";
	    print OUT "$label\n";
	}
	else {
	    die "\n\n Warning: Missing the id: $id\n\n";
	}
    }
    else {
	print OUT "$_\n";
    }
}
close(IN);
close(OUT);


exit 0;
