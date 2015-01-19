CC=g++

main.o: main.c++
	$(CC) -c -o main.o main.c++
	$(CC) -c -o mystuff.o mystuff.c++
	$(CC) -o stuff main.o mystuff.o -lm

clean:
	rm *.o stuff
