CC=g++
CFLAGS=-std=c++11

flaten_fasta.o: flaten_fasta.c++
	$(CC) $(CFLAGS) -c -o flaten_fasta.o flaten_fasta.c++
	$(CC) -o flaten_fasta flaten_fasta.o -lm

clean:
	rm -f *.o flaten_fasta
