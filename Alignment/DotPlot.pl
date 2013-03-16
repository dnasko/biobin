#!/usr/bin/perl

# Example program 2.  Compute the dot plot for two sequences, based
# only on exact matches.  Thus this program is equally useful for both
# nucleotide and amino acid sequences.  The input should be of the form
# <window length> <match criteria> <sequence 1> <sequence 2>.


# Define the desired output characters for easy modification.

$match_char    = "*";
$mismatch_char = " ";

# Make sure there are 4 inputs, store them for future use, and print them out.

if ( @ARGV != 4 )
{
  printf( "$0: <window length> <match criteria> <sequence 1> " .
          "<sequence 2>\n\n" );
  exit( 1 );
} # if

$window_length  = $ARGV[0];
$match_criteria = $ARGV[1];
$sequence_1     = $ARGV[2];
$sequence_2     = $ARGV[3];

printf( " Window length: $window_length\n" );
printf( "Match criteria: $match_criteria\n" );
printf( "    Sequence 1: $sequence_1\n" );
printf( "    Sequence 2: $sequence_2\n\n" );

# Set the size of the plot dimensions, based upon the length of
# the strings and the window length.

$sizex = length( $sequence_1 ) - $window_length + 1;
$sizey = length( $sequence_2 ) - $window_length + 1;

# Do some error checking on the inputs to be sure that they make sense.

if ( $match_criteria > $window_length )
{
  printf( "$0: Window length ($window_length) must be >= Match " .
          "criteria ($match_criteria).\n\n" );
  exit( 2 );
} # if

if (    ( $sizex < 0 )
     || ( $sizey < 0 )
   )
{
  printf( "$0: Each input sequence must be of length >= Window length " .
          "($window_length).\n\n" );
  exit( 3 );
} # if

# Draw a line of dashes at the top of the plot.
draw_line( $sizex + 2 );

# Run through all possible plot positions, with sequence 2 on the y-
# axis, and sequence 1 on the x-axis.

for ( $y = 0; $y < $sizey; $y++ )
{
  # Extract the section of sequence 2 to be compared against sequence 1.
  $substr2 = substr( $sequence_2, $y, $window_length );
  printf( "|" );

  for ( $x = 0; $x < $sizex; $x++ )
  {
    # Extract the section of sequence 1 to be compared against $substr2.
    $substr1 = substr( $sequence_1, $x, $window_length );

    # If the number of matches is >= the match criteria, a match has
    # occurred.  Mark the appropriate character in the dot plot.
    if ( num_matches( $substr1, $substr2 ) >= $match_criteria )
    {
      $dotplot[$x][$y] = $match_char;
    } # if
    else
    {
      $dotplot[$x][$y] = $mismatch_char;
    } # else
    printf( "$dotplot[$x][$y]" );
  } # for x

  printf( "|\n" );
} # for y

# Draw a line of dashes at the bottom of the plot.
draw_line( $sizex + 2 );
printf( "\n" );


# Function to compute the number of character positions at which two
# strings of equal length match.

sub num_matches
{
  my( $a, $b ) = @_;
  my( $i, $matches );

  for ( $i = 0; $i < length( $a ); $i++ )
  {
    if ( substr( $a, $i, 1 ) eq substr( $b, $i, 1 ) )
    {
      $matches++;
    } # if
  } # for i

  return $matches;
} # num_matches


# Function to draw a line of dashes, of a given length.

sub draw_line
{
  my( $len ) = @_;
  my( $i );

  for ( $i = 0; $i < $len; $i++ )
  {
    printf( "-" );
  } # for i

  printf( "\n" );
} # draw_line
