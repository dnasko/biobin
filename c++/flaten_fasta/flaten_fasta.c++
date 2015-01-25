#include <iostream>
#include <fstream>
#include <string>
#include "flaten_fasta.h"
#include <regex>

using namespace std;

int main(int argc, char *argv[])
{
  if (argc < 2) print_usage(argv[0]);
  string line;
  ifstream myfile (argv[1]);
  string regex_str = ">";
  regex reg1(regex_str, regex_constants::icase);
  if (myfile.is_open())
    {
      while (myfile.good())
  	{
  	  getline(myfile,line);
	  if (regex_search(line, reg1))
	    {
	      cout << line << endl;
	    }	
	}
      myfile.close();
    }
  else
    cout << "\n\n ERROR! Unable to open the file: " << argv[0] << endl;
  return 0;
}
