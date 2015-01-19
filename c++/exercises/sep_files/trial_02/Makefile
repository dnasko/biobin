CC=g++

main.o: main.c++
	$(CC) -c -o main.o  main.c++
	$(CC) -c -o safestuff.o safestuff.c++
	$(CC) -o safestuff main.o safestuff.o -lm

clean:
	rm *.o safestuff
