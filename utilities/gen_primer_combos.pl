#!/usr/bin/perl -w
use strict;

my $primer = $ARGV[0];
my $name   = $ARGV[1];
$primer = uc( $primer );

my %AmbigBases = construct_hash();

my %Combo;
my @Seq = split(//, $primer);
my $combos = 1;
foreach my $base (@Seq) {
    if (exists $AmbigBases{$base}) {
	$combos *= scalar(@{$AmbigBases{$base}});
    }
}
for (my $i=1; $i<=$combos; $i++) {
    $Combo{$i} = "";
}
for(my $i=0;$i<scalar(@Seq);$i++) {
    if ($Seq[$i] !~ m/A|T|C|G/) {
	if (exists $AmbigBases{$Seq[$i]}) {
	    my $local_count = 0;
	    my @keys = sort { $Combo{$a} cmp $Combo{$b} } keys(%Combo);
	    foreach my $j (@keys) {
		$Combo{$j} = $Combo{$j} . ${$AmbigBases{$Seq[$i]}}[$local_count];
		$local_count++;
		if ($local_count == scalar(@{$AmbigBases{$Seq[$i]}})) { $local_count = 0; }
	    }
	}
	else {  die "\n Error: Primer/Adapter contains invalid ambgious base: $Seq[$i]\n Only A,C,G,T,W,S,M,K,R,Y,B,D,H,V, and N are acceptable.\n\n"; }
    }
    else {
	for (my $j=1;$j <= $combos; $j++) {
	    $Combo{$j} = $Combo{$j} . $Seq[$i];
	}
    }
}
my @tmp = ($name);
foreach my $ambig_adapter (sort {$a <=> $b} keys %Combo) {
    push (@tmp, $Combo{$ambig_adapter});
}

foreach my $i (keys %Combo) {
    print ">" . $name . "_" . $i . "\n" . $Combo{$i} . "\n";
}

sub construct_hash
{
    my %hash = (
        W => [ 'A', 'T' ],
        S => [ 'C', 'G' ],
        M => [ 'A', 'C' ],
        K => [ 'G', 'T' ],
        R => [ 'A', 'G' ],
        Y => [ 'C', 'T' ],
        B => [ 'C', 'G', 'T' ],
        D => [ 'A', 'G', 'T' ],
        H => [ 'A', 'C', 'T' ],
        V => [ 'A', 'C', 'G' ],
        N => [ 'A', 'C', 'G', 'T' ]
        );
    return(%hash);
}

exit 0;
