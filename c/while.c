#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char *argv[])
{
  char i = 0;
  printf ("Bet you can't type a 7\n");
  while (i != '7' )
    {
      i = getchar();
      getchar;
      printf ("Ha! You type %c.\n",i);
    }
  printf ("I'm done.\n");
}
