#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <iostream>
#include <fstream>

using namespace std;

int main (int argc, char **argv)
{
  char *infile = NULL;
  char *outfile = NULL;
  int index;
  int c;
 
  opterr = 0;
  
  while ((c = getopt (argc, argv, "i:o:")) != -1)
    switch (c)
      {
      case 'i':
	infile = optarg;
	// printf ("Input file = %s\n",infile);

	break;
      case 'o':
	outfile = optarg;
	// printf ("Output file = %s\n",outfile);
	break;
      case '?':
	if (optopt == 'i')
	  fprintf (stderr, "Option -%i requires an argument.\n", optopt);
	else if (isprint (optopt))
	  fprintf (stderr, "Unknown option `-%c'.\n", optopt);
	else
	  fprintf (stderr,
		   "Unknown option character `\\x%x'.\n",
		   optopt);
	return 1;
      default:
	abort();
      }
  printf (" Input File = %s\n Output File = %s\n\n",
	  infile, outfile);

  for (index = optind; index < argc; index++)
    printf ("Non-option argument %s\n", argv[index]);

  ofstream outfile_handle(outfile);
  outfile_handle << "Hi" << endl;
  outfile_handle.close();
  return 0;
}
