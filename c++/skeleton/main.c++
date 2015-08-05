#include <iostream>
#include "skeleton.h"

using namespace std;

double version = 0.1;

int main(int argc, char *argv[])
{
  if (argc < 2) { Help(version); }
  return 0;
}
