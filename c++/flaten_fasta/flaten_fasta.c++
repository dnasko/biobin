#include <iostream>
#include <fstream>
#include <string>
#include <regex>

using namespace std;

int main(int argc, char** argv)
{
  string line;
  ifstream myfile (argv[1]);
  if (myfile.is_open())
    {
      while (myfile.good())
	{
	  getline(myfile,line,'>');
	  cout << line << endl << endl;
	}
      myfile.close();
    }
  else
    cout << "\n\n ERROR! Unable to open the file: " << argv[0] << endl;
  return 0;
}
