#include <iostream>

using namespace std;

void Combine(string first, string second);
void Combine(int first, int second);

int main()
{
  Combine("Dan", "Nasko");
  Combine(3,1988);
  return 0;
}

void Combine(string first, string second)
{
  cout << first << " " << second << endl;
}
void Combine (int first, int second)
{
  cout << first << " " << second << endl;
}
