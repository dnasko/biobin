CC=g++

flaten_fasta.o: flaten_fasta.c++
	$(CC) -c -o flaten_fasta.o flaten_fasta.c++
	$(CC) -o flaten_fasta flaten_fasta.o -lm

clean:
	rm -f *.o flaten_fasta
