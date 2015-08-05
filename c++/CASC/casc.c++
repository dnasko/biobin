// =============================================================================
// CASC
// https://github.com/dnasko/CASC
// 
// program written by
//                    Dan Nasko
//                    University of Delaware, Center for Bioinformatics and Computational Biology (CBCB)
//                    Newark, Delaware, 19711
//                    Email dnasko@UDel.edu
//                 at
//                    K. Eric Wommack's Lab
//                    Delaware Biotechnology Institute
//                    Newark, Delaware, 19711
//                    Email wommack@dbi.udel.edu
//
// Modified by:
//                    Dan Nasko
//                    University of Delaware, Center for Bioinformatics and Computational Biology (CBCB)
//                    Newark, Delaware, 19711
//                    Email dnasko@UDel.edu 
// ============================================================================= 

#include "casc-common.h"

using namespace std;

double version = 0.1;

int main(int argc, char *argv[])
{
  if (argc < 2) { Help(version); }
  string file = argv[1];
  int seqs = NumSeqs(file);
  cout << " There are " << seqs << " sequences in: " << file << endl;
  return 0;
}
