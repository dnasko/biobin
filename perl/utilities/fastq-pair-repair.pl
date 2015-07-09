#!/usr/bin/perl -w

# MANUAL FOR fastq-pair-repair.pl

=pod

=head1 NAME

$0 -- finds intact mates and single sequences from paired fastq

=head1 SYNOPSIS

 fastq-pair-repair.pl --PE1 fwd.fastq[.gz] --PE2 rev.fastq[.gz] [--zip] [--SRA]
                     [--help] [--manual]

=head1 DESCRIPTION

Accepts two fastq files representing a single paired-end or mate-paired illumina 
library.  Validates mates between files and sorts out any unpaired sequences and 
parses into separate files.  Useful after trimming to sort out broken pairs.  

=head2 FASTQ FORMAT

Default: Sequence name is all characters between beginning '@' and first space or '/'.  Also first 
character after space or '/' must be a 1 or 2 to indicate pair relationship.  
Compatible with both original Illumina (Casava version 1.7 and previous) and newer
(Casava >= 1.8) formatted headers:
  @B<HWUSI-EAS100R:6:73:941:1973#0>/I<1>
  @B<EAS139:136:FC706VJ:2:2104:15343:197393> I<2>:Y:18:ATCACG

Also compatible with NCBI Sequence Read Archive (SRA) fastq naming convention by 
using argument (B<--SRA>):
  @B<ERR005143.1> ID49_20708_20H04AAXX_R1:7:1:41:356/I<2>
 
=head1 OPTIONS

=over 3

=item B<-a, --PE1>=FILE

One of two input files must be specified (e.g. forward reads).  (Required) 

=item B<-b, --PE2>=FILE

One of two input files must be specified (e.g. reverse reads).  (Required) 

=item B<-s, --SRA>

Specify that fastq has NCBI SRA format sequence headers.  See I<FASTQ FORMAT> section in manual.  (Optional)

=item B<-z, --zip>

Specify that input is gzipped fastq (output files will also be gzipped).  Slower, but space-saving.  (Optional)

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries (all standard in most Perl installs).
   IO::Compress::Gzip
   IO::Uncompress::Gunzip
   Getopt::Long
   File::Basename
   Pod::Usage

=head1 AUTHOR

Written by Shawn Polson, 
Center for Bioinformatics and Computational Biology Core Facility, University of Delaware.

=head1 REPORTING BUGS

Report bugs to help@bioinformatics.udel.edu

=head1 COPYRIGHT

Copyright 2012 Shawn Polson.  
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  

Please acknowledge author and affiliation in published work arising from this script's 
usage <http://bioinformatics.udel.edu/Core/Acknowledge>.

=cut

# CODE FOR fastq-pair-repair.pl

use strict;
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS
my($PE1,$PE2,$zip,$sra,$help,$manual);

GetOptions (	
				"a|PE1=s"	=>	\$PE1,
				"b|PE2=s"	=>	\$PE2,
				"s|SRA=s"	=>	\$sra,
				"z|zip" 	=>	\$zip,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose  => 2)  if ($manual);
pod2usage( -verbose => 1 )  if ($help);
pod2usage( -msg  => "ERROR!  Required arguments -a and/or -b not found.\n", -exitval => 2, -verbose => 1)  if (! $PE1 || ! $PE2);


# PARSE OUTPUT FILEBASE
my $out1=fileparse($PE1, qr/\.[^.]*(\.gz)?$/);
my $out2=fileparse($PE2, qr/\.[^.]*(\.gz)?$/);

# FILE HANDLES
my($DATA,$PAIR1,$PAIR2,$SNGL1,$SNGL2);

# OPEN PE1
if($zip)
{	$DATA = IO::Uncompress::Gunzip->new( $PE1 ) or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
}
else
{	open ($DATA,$PE1) || die $!;
}

my %seqs;

# REG EXP FOR FASTQ HEADERS
my $hdr_ptrn;
unless($sra)
{	# Illumina 1-1.7:	@HWUSI-EAS100R:6:73:941:1973#0/1
	# Illumina 1.8+:	@EAS139:136:FC706VJ:2:2104:15343:197393 1:Y:18:ATCACG
	$hdr_ptrn='^\@(\S+)[\/ ][12]';
}
else
{	# NCBI SRA:	@ERR005143.1 ID49_20708_20H04AAXX_R1:7:1:41:356/2
	$hdr_ptrn='^\@(\S+)\ .+\/[12]$';
}

# PROCESS PE1
while(<$DATA>)
{
	if (/$hdr_ptrn/)
	{	$seqs{$1}=$_;
		$seqs{$1}.=<$DATA>.<$DATA>.<$DATA>;
	}
	else
	{	die "ERROR! File format error in $PE1 near line ".$..".\n$_\n";
	}
}
close $DATA;

# OPEN PE2 AND OUTPUTS
if($zip)
{	$DATA = IO::Uncompress::Gunzip->new( $PE2 ) or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
	$PAIR1 = IO::Compress::Gzip->new( "$out1.paired.fastq.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
	$PAIR2 = IO::Compress::Gzip->new( "$out2.paired.fastq.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
	$SNGL1 = IO::Compress::Gzip->new( "$out1.single.fastq.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
	$SNGL2 = IO::Compress::Gzip->new( "$out2.single.fastq.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
}
else
{	open ($DATA,$PE2) or die $!;
	open ($PAIR1,"> $out1.paired.fastq") or die $!;
	open ($PAIR2,"> $out2.paired.fastq") or die $!;
	open ($SNGL1,"> $out1.single.fastq") or die $!;
	open ($SNGL2,"> $out2.single.fastq") or die $!;
}

# PROCESS PE2 AND OUTPUT PAIRS/SINGLES FROM PE2
while(<$DATA>)
{	if (/$hdr_ptrn/)
	{
		if ($seqs{$1})
		{	print $PAIR1 $seqs{$1};
			undef $seqs{$1};
			$_.=<$DATA>.<$DATA>.<$DATA>;
			print $PAIR2 $_;
		}
		else
		{	$_.=<$DATA>.<$DATA>.<$DATA>;
			print $SNGL2 $_;
		}
	}
	else
	{	die "ERROR! File format error in $PE2 near line ".$..".\n$_\n";
	}
}

# PRINT SINGLES FROM PE1
foreach my $key(keys %seqs)
{
	if (($seqs{$key})&&($seqs{$key} ne ""))
	{
		print $SNGL1 $seqs{$key};
	}
}

close $DATA;
close $PAIR1;
close $PAIR2;
close $SNGL1;
close $SNGL2;

exit 0;
