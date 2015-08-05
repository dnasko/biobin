CC=g++
CFLAGS=-std=c++11

skeleton.o: main.c++
	$(CC) $(CFLAGS) -c -o main.o main.c++
	$(CC) $(CFLAGS) -c -o skeleton.o skeleton.c++
	$(CC) -o skeleton main.o skeleton.o -lm

clean:
	rm -f *.o skeleton
