#include <iostream>

using namespace std;

int main()
{
  string HorribleMovie = "L.A. Confidential";
  string *ptrToString = &HorribleMovie;

  for(unsigned i = 0; i < HorribleMovie.length(); i++)
    {
      cout << (*ptrToString)[i] << " ";
    }
  cout << endl;
  return 0;
}
