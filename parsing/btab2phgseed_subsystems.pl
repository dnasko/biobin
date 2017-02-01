#!/usr/bin/perl -w

# MANUAL FOR btab2phgseed_subsystems.pl

=pod

=head1 NAME

btab2phgseed_subsystems.pl -- Parses a BTAB of Phage SEED results to annotate queries

=head1 SYNOPSIS

 btab2phgseed_subsystems.pl --btab=/Path/to/infile.btab --phgseed=/Path/to/phage_seed.fasta --out=/Path/to/output.txt
                     [--help] [--manual]

=head1 DESCRIPTION

 Will parse through a BTAB of phage seed results to annotate each query
 based on best cumulative bit score. Ignores hits to "no subsystem" and
 "ACLAME_Phage_proteins_with_unknown_functions"
 
=head1 OPTIONS

=over 3

=item B<-b, --btab>=FILENAME

Input blast results in tabular blast format. (Required) 

=item B<-p, --phgseed>=FILENAME

Input Phage SEED FASTA file. (Required)

=item B<-o, --out>=FILENAME

Output file in tabular format. (Required) 

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

Copyright 2017 Daniel Nasko.  
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
my($btab,$phgseed,$out,$help,$manual);

GetOptions (	
                                "b|btab=s"	=>	\$btab,
                                "p|phgseed=s"   =>      \$phgseed,
				"o|out=s"	=>	\$out,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --btab not found.\n\n", -exitval => 2, -verbose => 1)  if (! $btab );
pod2usage( -msg  => "\n\n ERROR!  Required argument --phgseed not found.\n\n", -exitval => 2, -verbose => 1)  if (! $phgseed );
pod2usage( -msg  => "\n\n ERROR!  Required argument --out not found.\n\n", -exitval => 2, -verbose => 1)  if (! $out);

my %Lookup;
my %Running;
my %Results;

# >fig|682370.2.peg.4 [Phage capsid protein # ACLAME 50] [ACLAME_Phage_head; Phage_capsid_proteins] [682370.2] [Streptococcus phage ALQ13.2]

## Gathering some lookup information from the Phage SEED FASTA file...
open(IN,"<$phgseed") || die "\n Cannot open the file: $phgseed\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	my $h = $_;
	$h =~ s/^>//;
	if ($h =~ m/(\[ACLAME_\w+)/) {
	    my $subsystem = $1;
	    $subsystem =~ s/^\[//;
	    my $fig = $h;
	    $fig =~ s/ .*//;
	    my $info = $h;
	    $info =~ s/.*?\[//;
	    $info =~ s/\].*//;
	    $info =~ s/ # .*//;
	    $Lookup{$fig} = $info;
	}
	else {
	    my $fig = $h;
	    $fig =~ s/ .*//;
	    $Lookup{$fig} = "No_subsystem";
	}
    }
}
close(IN);

## Now we're going to parse through the results...
open(IN,"<$btab") || die "\n Cannot open the file: $btab\n";
while(<IN>) {
    chomp;
    my @a = split(/\t/, $_);
    if (exists $Lookup{$a[1]}) {
	unless ( $Lookup{$a[1]} eq "ACLAME_Phage_proteins_with_unknown_functions" || $Lookup{$a[1]} eq "No_subsystem") {
	    $Running{$a[0]}{$Lookup{$a[1]}} += $a[11];
	}
    }
    else { die "\n Cannot find $a[1] here's the line:\n\n$_\n"; }
}
close(IN);

## Time to dump the results...
open(OUT,">$out") || die "\n Cannot write to the output file: $out\n";
print OUT "#query\tannotation\tsum_bitscore\n";
foreach my $i (keys %Running) {
    my $max = 0;
    my $winner;
    foreach my $j (keys %{$Running{$i}}) {
	if ($max < $Running{$i}{$j}) {
	    $max = $Running{$i}{$j};
	    $winner = $j;
	}
    }
    if ($winner eq "Phage protein") {
	# print OUT $i . "\n";
    }
    $Results{$winner}++;
    print OUT $i . "\t" . $winner . "\t" . $max . "\n";
}
close(OUT);

## Old routine that would dump the summary of more frequently annotated genes
# foreach my $i (keys %Results) {
#     # print $i . "\t" . $Results{$i} . "\n";
# }

exit 0;
