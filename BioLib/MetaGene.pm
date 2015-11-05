package MetaGene;
use strict;
use warnings;

## MetaGene.pm Version 1.0

## strip_coords
## A subroutine to strip the coordinates from the end of each seq header
##      Version 1.0
sub strip_coords
{
    my($header) = @_;
    $header =~ s/ .*//;
    my $r_header = scalar reverse $header;
    $r_header =~ s/^.*?_//;
    $r_header =~ s/^.*?_//;
    $r_header =~ s/^.*?_//;
    $header = scalar reverse $r_header;
    return $header;
}

1;
