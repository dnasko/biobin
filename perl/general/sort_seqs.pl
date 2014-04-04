#!/usr/bin/perl -w

# MANUAL FOR sort_seqs.pl

=pod

=head1 NAME

sort_seqs.pl -- Sorts sequences in a FASTA files by size or size and lex-order

=head1 SYNOPSIS

 sort_seqs.pl -in /Path/to/infile.fasta -out /Path/to/output.fasta [-lex] [-rev]
                     [--help] [--manual]

=head1 DESCRIPTION

 By default this script sorts sequences in a FASTA file from longest to shortest. Optionally you can use [-rev] to sort from smallest to largest or [-lex] to short by lengths first then by lexicographical order
 
=head1 OPTIONS

=over 3

=item B<-i, --in>=FILENAME

Input file in FASTA format. (Required) 

=item B<-o, --out>=FILENAME

Output file in FASTA format. (Required) 

=item B<-l, --lex>=INT

Flag to also sort lexicographically

=item B<-r, --rev>=INT

Flag to sort smallest to longest

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
my($infile,$outfile,$rev,$lex,$help,$manual);

GetOptions (	
				"i|in=s"	=>	\$infile,
				"o|out=s"	=>	\$outfile,
				"l|lex"         =>      \$lex,
                                "r|rev"         =>      \$rev,
                                "h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument -infile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $infile );
pod2usage( -msg  => "\n\n ERROR!  Required argument -outfile not found.\n\n", -exitval => 2, -verbose => 1)  if (! $outfile);

if ($rev) {
    if ($lex) {
	print " Sorting from smallest to largest THEN by lex\n";
    }
    else {
	print " Sorting from smallest to largest.\n";
    }
}
elsif ($lex) {
    print " Sorting from largest to smallest THEN by lex.\n";
}
else {
    print " Sorting from largest to smallest.\n";
}

if ($infile =~ m/\.gz$/) { ## if a gzip compressed infile
    open(IN,"gunzip -c $infile |") || die "\n\n Cannot open the input file: $infile\n\n";
}
else { ## If not gzip comgressed
    open(IN,"<$infile") || die "\n\n Cannot open the input file: $infile\n\n";
}

my %Fasta;
my %SiZeS = ();
my $l = 0; ## just counts what line number we're on in the FASTA file.
my ($header,$seq);
my $seqs = 0;

while(<IN>) {
    chomp;
    if ($l == 0) {
	$header = $_;
	$header =~ s/^>//;
	$header =~ s/ .*//;
	$seqs++;
    }
    else {
	if ($_ =~ m/^>/) {
	    $Fasta{$header} = $seq;
	    if (exists $SiZeS{length($seq)}) {
		push @{ $SiZeS{length($seq)} }, $header;
	    }
	    else {
		$SiZeS{length($seq)}[0] = $header;
	    }
	    $header = $_;
	    $header =~ s/^>//;
	    $header =~ s/ .*//;
	    $seq = "";
	    $seqs++;
	}
	else {
	    $seq = $seq . $_;
	}
    }
    $l++;
}
$Fasta{$header} = $seq;
close(IN);

print STDOUT " Successfully read $seqs sequences into memory.\n Sorting . . . \n";
open(OUT,">$outfile") || die "\n\n Error: Cannot open the outfile: $outfile\n\n";
if ($rev) {
    if ($lex) {
	foreach my $i (sort {$a<=>$b} keys %SiZeS) {
	    my %Sort;
	    foreach my $j (@{$SiZeS{$i}}) {
		if (exists $Sort{$Fasta{$j}}) {
		    push @{ $Sort{$Fasta{$j}} }, $j;
		}
		else {
		    $Sort{$Fasta{$j}}[0] = $j;
		}
	    }
	    foreach my $j (sort keys %Sort) {
		foreach my $k (@{$Sort{$j}}) {
		    print OUT ">$k\n$j\n";
		}
	    }
	}
    }
    else { ################
	foreach my $i (sort {$a<=>$b} keys %SiZeS) {
	    foreach my $j (@{$SiZeS{$i}}) {
		print OUT ">$j\n";
		if (exists $Fasta{$j}) {
		    print OUT "$Fasta{$j}\n"
		}
		else {
		    die "Error: tried to reference a sequence that isn't in the hash.\n"
		}
	    }
	}
    }
}
else {
    if ($lex) {
	foreach my $i (sort {$b<=>$a} keys %SiZeS) {
            my %Sort;
            foreach my $j (@{$SiZeS{$i}}) {
                if (exists $Sort{$Fasta{$j}}) {
                    push @{ $Sort{$Fasta{$j}} }, $j;
                }
                else {
                    $Sort{$Fasta{$j}}[0] = $j;
                }
            }
            foreach my $j (sort keys %Sort) {
                foreach my $k (@{$Sort{$j}}) {
                    print OUT ">$k\n$j\n";
		}
            }
        }
    }
    else {
	foreach my $i (sort {$b<=>$a} keys %SiZeS) {
	    foreach my $j (@{$SiZeS{$i}}) {
		print OUT ">$j\n";
		if (exists $Fasta{$j}) {
		    print OUT "$Fasta{$j}\n"
	    }
		else {
		    die "Error: tried to reference a sequence that isn't in the hash.\n"
		}
	    }
	}
    }
}
close(OUT);


exit 0;
