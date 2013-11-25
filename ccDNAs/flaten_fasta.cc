#include <iostream>
#include <fstream>
#include <string>
#include <regex>
using namespace std;

int main()
{
  std::string line;
  ifstream myfile ("test.fasta");
  if (myfile.is_open())
    {
      while ( myfile.good() )
	{
	  getline(myfile,line);
	  std::regex rx (">");
	  cout << line << endl;
	}
      myfile.close();
    }
  else
    cout << "\n\n ERROR: Unable to open file\n" << endl;
  return 0;
}
