// =============================================================================
// FASTA Size Filter
//
// program written by
//                    Dan Nasko
//                    Univ. of Delaware, CBCB
//                    Newark, DE 19711
//                    Email dnasko@udel.edu
//                 at
//                    K. Eric Wommack's lab
//                    Delaware Biotechnology Institute
//                    Newark, DE 19711
//                    Email wommack@dbi.udel.edu
//
// ============================================================================= 

#include "fasta_size_filter-common.h"

using namespace std;

int main(int argc, char *argv[])
{
  if (argc < 3 || argc > 3) { Help(); }
  int cutoff = atoi(argv[1]);
  string infile = argv[2];
  cout << endl << endl << " Working on: " << infile << endl;
  cout << " Will toss all sequences less than: " << cutoff << endl << endl;

  ifstream input(infile);
  if(!input.good()){
    cerr << "Error opening '"<< infile <<"'. Bailing out." << endl;
    return -1;
  }

  string line, name, content;

  while( getline( input, line ).good() ){
    if( line.empty() || line[0] == '>' ){ // Identifier marker
      if( !name.empty() ){ // Print out what we read from the last entry
	cout << name << " : " << content << endl;
	name.clear();
      }
      if( !line.empty() ){
	name = line.substr(1);
      }
      content.clear();
    } else if( !name.empty() ){
      if( line.find(' ') != std::string::npos ){ // Invalid sequence--no spaces allowed
	name.clear();
	content.clear();
      } else {
	content += line;
      }
    }
  }
  if( !name.empty() ){ // Print out what we read from the last entry
   cout << name << " : " << content << endl;
  }
  
  return 0;
}
