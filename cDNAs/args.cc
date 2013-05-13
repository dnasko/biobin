#include <stdio.h>

int main ( int argc, char *argv[] ) {
  if (argc != 2) { /* argc should be two for correct execution*/
    /* printing argv[0] assuming it is the program name */
    printf( "\n\n usage: %s filename\n\n", argv[0] );
  }
  else {
    /* assume argv[1] is a file to open */
    FILE *file = fopen( argv[1], "r" );
    
    /* fopen returns 0, the NULL pointer, on failure */
    if ( file == 0 ) {
      printf( "\n could not open file\n" );
    }
    else {
      int x;
      /* read one character at a time from file, stopping at EOF, which
	 indicates the end of the file. Note that the idiom of "assign
	 to a variable, check the value" used below works because the
	 assignment statement evaluates to the value assigned. */
      while ( ( x = fgetc( file ) ) != EOF ) {
	printf( "%c", x );
      }
      fclose( file );
      printf("\n\n");
    }
  }
}
