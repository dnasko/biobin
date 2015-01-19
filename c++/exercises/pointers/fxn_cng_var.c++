#include <iostream>

using namespace std;

void ChangesAreGood(int myparam)
{
  myparam += 10;
  cout << "Inside the fxn: " << myparam << endl;
}

int main()
{
  int mynumber = 10;
  cout << "Before the fxn: " << mynumber << endl;

  ChangesAreGood(mynumber);
  cout << "After the fxn: " << mynumber << endl;

  return 0;
}
