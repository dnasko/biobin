#include <iostream>

using namespace std;

/* Information */
char ff_ver[]  = "0.0";

int print_usage (char *arg) {
  //  cout << ff_ver << "\n\n" ;
  cout << "USAGE" << endl;
  cout << "  flaten_fasta [-h] [-help] -i input.fasta -o output.fasta" << endl << endl;
  cout << "DESCRIPTION" << endl;
  cout << "   Application to flaten a FASTA file, i.e. remove line breaks" << endl;
  cout << "   from the sequence data." << endl << endl;
  exit(1);
}
