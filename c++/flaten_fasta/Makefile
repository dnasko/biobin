CC=g++

hellomake: flaten_fasta.cc
	$(CC) -c flaten_fasta.cc
	$(CC) flaten_fasta.cc -o "flaten_fasta" -L flaten_fasta.o

clean:
	rm -f *.o flaten_fasta
