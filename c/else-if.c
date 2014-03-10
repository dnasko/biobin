#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char *argv[])
{
  char Buffer[10];
  if (argc < 2)            /* Something on the cmd line? */
    {
      printf("Usage: we need an option.\n");
      exit(1);
    }
  strncpy(Buffer,argv[1],9);  /* Move it to buffer */
  if (!strcmp(Buffer,"/?"))   /* Compare List */
    printf("They want help.\n");
  else if(!strcmp(Buffer,"/A"))
    printf("Option A\n");
  else if(!strcmp(Buffer,"/B"))
    printf("Option B\n");
  else
    printf("Unknown option\n"); /* None of the above*/
}
