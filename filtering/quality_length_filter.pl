#!/usr/bin/perl -w

# MANUAL FOR quality_length_filter.pl

=pod

=head1 NAME

quality_length_filter.pl -- Filters FASTA or FASTQ file based on user inputs for
                            SIZE or MEAN QUALITY restrictions

=head1 SYNOPSIS

 quality_length_filter.pl --input /path/to/sequence.fastq --minlen 20 --maxlen 1000 --minqual 12
                     [--help] [--manual]

Notes:
[1] IF YOU'RE FILTERING BY QUALITY YOU WILL NEED A FASTQ FILE
[2] NUMBERS ARE INCLUSIVE (i.e. --minlen 20 means length >=20 will be accepted)
[3] LEAVING A FIELD BLANK IS THE SAME AS SAYING "NULL" (i.e. --maxqual NULL means there is no max)
    Notice I do this in the example above.
[4] OUTPUTS ARE WRITTEN TO WHATEVER DIRECTORY YOU'RE IN

=head1 DESCRIPTION

Runs through your input FASTA or FASTQ file and will write out only
those sequences which match your input criteria.

=head1 OPTIONS

=over 3

=item B<-i, --input>=FILENAME

Input file in FASTA or FASTQ format. (Required) 

=item B<-a, --minlen>=INTEGER

Minimum size of sequence you would like to keep. (Default=0)

=item B<-b, --maxlen>=INTEGER

Maximum size of sequence you would like to keep. (Default= +infinity)

=item B<-c, --minqual>=INTEGER

Minimum mean quality of sequence you would like to keep. (Default=0)

=item B<-d, --maxqual>=INTEGER

Maximum mean quality of sequence you would like to keep. (Default= +infinity)

=item B<-o, --outfile>=FILENAME

Output file in FASTA or FASTQ format. (Required)

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
my($input,$outfile,$help,$manual);

#ARGUMENTS WITH DEFAULT
my $minlen = 0;
my $maxlen = 9**9**9;       ## close enough to positive infinity for me...
my $minqual = 0;
my $maxqual = 9**9**9;

GetOptions (	
				"i|input=s"	=>	\$input,
				"a|minlen=i"	=>	\$minlen,
				"b|maxlen=i"	=>	\$maxlen,
                                "c|minqual=f"	=>	\$minqual,
				"d|maxqual=f"	=>	\$maxqual,
                                "o|outfile=s"   =>      \$outfile,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage(-verbose => 1)  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required arguments --input and/or --outfile missing or not found.\n", -exitval => 2, -verbose => 1)  if (! $input || ! $outfile);
my $first_line = `head -n1 $input`;
pod2usage( -msg  => "\n\n ERROR!  You've supplied quality constraints but you've submitted a FASTA file!!!\n\n", -exitval => 2, -verbose => 1)  if ( $minqual != 0 && $maxqual !=  9**9**9 && $first_line =~ m/^>/);

my $start_time = time();
## Variables needed for FASTQ parsing
my $lc = 0;                 ## Global line counting variable needed for reading FASTQ
my $size_flag = 0;          ## binary flag for size being correct
my $quality_flag = 0;       ## binary flag for the quality being correct
my $sum = 0;                ## little sum variable to help caluclate the average quality score
my ($current_header,$current_sequence,$current_comment,$current_quality) = ("","","","");

## If the input was a FASTA file
if ($first_line =~ m/^>/) {
    open(OUT,">$outfile") || die "\n\nCannot open the output file $outfile\n\n";
    open(IN,"<$input") || die "\n Error: Cannot open the FASTA file: $input\n";
    while(<IN>) {
	chomp;
	if ($_ =~ m/^>/) {
	    unless (length($current_header) == 0) {
		my $length = length($current_sequence);
		if ($length >= $minlen && $length <= $maxlen) {
		    print OUT "$current_header\n$current_sequence\n";
		}
	    }
	    $current_header = $_;
	    $current_sequence = "";
	}
	else {
	    $current_sequence = $current_sequence . $_;
	}
    }
    close(IN);
    my $length = length($current_sequence);
    if ($length >= $minlen && $length <= $maxlen) {
	print OUT "$current_header\n$current_sequence\n";
    }
    close(OUT);
    my $end_time = time();
    my $running_time = $end_time - $start_time;
    print "\nInput File:$input\nFormat: FASTA\nMinimum Length: $minlen\nMaximum Length: $maxlen\nMinimum Mean Quality: $minqual\nMaximum Mean Quality: $maxqual\nRunning Time: $running_time seconds\nOutput written to: $outfile\n\n";
}
else {
    open(IN,"<$input") || die "\n\nCannot open the input file $input\n\n";
    open(OUT,">$outfile") || die "\n\nCannot open the output file $outfile\n\n";
    while(<IN>) {
        chomp;
        if ($lc == 0) {
            $current_header = $_;
        }
        elsif ($lc == 1) {
            $current_sequence = $_;
            my $size = length($_);
            if ($size >= $minlen && $size <= $maxlen) {
                $size_flag = 1;
            }
        }
        elsif ($lc == 2) {
            $current_comment = $_;
        }
        elsif ($lc == 3) {
            $current_quality = $_;
            my @QUALITY = split(//, $_);
            foreach my $q (@QUALITY) {
                my $value = ord($q) - 33;
                $sum += $value;
            }
            my $average = $sum/@QUALITY;
            if ($average >= $minqual && $average <= $maxqual) {
                $quality_flag = 1;
            }
        }
        if ($size_flag == 1 && $quality_flag == 1) {
            print OUT "$current_header\n$current_sequence\n$current_comment\n$current_quality\n";
        }
        $lc++;
        if ($lc == 4) { $lc = 0; $size_flag = 0; $quality_flag = 0; $sum=0;}
    }
    close(OUT);
    close(IN);
    my $end_time = time();
    my $running_time = $end_time - $start_time;
    print "\nInput File:$input\nFormat: FASTQ\nMinimum Length: $minlen\nMaximum Length: $maxlen\nMinimum Mean Quality: $minqual\nMaximum Mean Quality: $maxqual\nRunning Time: $running_time seconds\nOutput written to: $outfile\n\n";
}










