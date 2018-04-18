CC=ldc2
CFLAGS=-O -enable-inlining -Hkeep-all-bodies

all: xor

%: %.d
	$(CC) $(CFLAGS) -of$@ $<
	strip $@

clean:
	rm xor *.o
