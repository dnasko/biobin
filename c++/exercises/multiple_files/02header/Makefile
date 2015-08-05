CC=g++
CFLAGS=-std=c++11

gccontent.o: main.c++
	$(CC) $(CFLAGS) -c -o main.o main.c++
	$(CC) $(CFLAGS) -c -o gccontent.o gccontent.c++
	$(CC) -o gccontent main.o gccontent.o -lm

clean:
	rm -f *.o gccontent
