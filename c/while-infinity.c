#include <stdio.h>

int main (int argc, char *argv[])
{
  char i = 0;
  printf ("Bet you can't type a 7\n");
  while (1)
    {
      i = getchar();
      getchar;
      if (i == '7')
	{
	  break;
	}
      printf ("Ha! You type %c.\n",i);
    }
  printf ("I'm done.\n");
}
