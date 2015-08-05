CC=g++
CFLAGS=-std=c++11

casc.o: casc.c++
	$(CC) $(CFLAGS) -c -o casc.o casc.c++
	$(CC) $(CFLAGS) -c -o casc-common.o casc-common.c++
	$(CC) -o CASC casc.o casc-common.o -lm

install:
	cp CASC /usr/local/bin

clean:
	rm -f *.o CASC /usr/local/bin/CASC
