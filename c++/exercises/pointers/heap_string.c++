#include <iostream>

using namespace std;

int main()
{
  string *Password = new string;
  *Password = "The egg salad was not fresh";
  cout << *Password << endl;
  cout << (*Password).length() << endl;
  cout << Password->length() << endl;
  return 0;
}
