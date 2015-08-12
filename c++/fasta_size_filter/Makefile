CC=g++
CFLAGS=-std=c++11

fasta_size_filter.o: fasta_size_filter.c++
	$(CC) $(CFLAGS) -c -o fasta_size_filter.o fasta_size_filter.c++
	$(CC) $(CFLAGS) -c -o fasta_size_filter-common.o fasta_size_filter-common.c++
	$(CC) -o fasta_size_filter fasta_size_filter.o fasta_size_filter-common.o -lm

clean:
	rm -f *.o fasta_size_filter
