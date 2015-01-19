#include <iostream>
#include <fstream>
#include <string>
#include <regex>

using namespace std;

int main(int argc, char** argv)
{
  int line_count = 0;
  string line;
  ifstream myfile (argv[1]);
  if (myfile.is_open())
    {
      while (myfile.good())
	{
	  getline(myfile,line);
	  if (line_count == 0)
	    {
	      cout << line << endl;
	    }
	  else if (std::regex_match (line, std::regex("(>)(.*)") ))
	    {
	      cout << endl << line << endl;
	    }
	  else {
	    cout << line;
	  }
	  line_count++;
	}
      myfile.close();
      cout << endl;
    }
  else
    cout << "\n\n ERROR! Unable to open the file: " << argv[0] << endl;
  return 0;
}
