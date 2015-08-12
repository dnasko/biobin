#include "fasta_size_filter-common.h"

using namespace std;

int Help()
{
  cerr << " ======= FASTA Size Filter Version " << PROG_VERSION << " ======= " << endl;
  cerr << endl;
  cerr << endl;
  cerr << " Usage: fasta_size_filter 600 input.fasta > output.filtered.fasta" << endl;
  cerr << endl;
  cerr << "   size cut-off   (Required)" << endl;
  cerr << "   input filename (Required)" << endl;
  cerr << endl;
  cerr << endl;
  return 0;
}
