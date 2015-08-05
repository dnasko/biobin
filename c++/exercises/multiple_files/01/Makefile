CC=g++
CFLAGS=-std=c++11

01.o: main.c++
	$(CC) $(CFLAGS) -c -o main.o main.c++
	$(CC) $(CFLAGS) -c -o gccontent.o gccontent.c++
	$(CC) -o 01 main.o gccontent.o -lm

clean:
	rm -f *.o 01
