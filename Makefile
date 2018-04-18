CC=ldc2
CFLAGS=-O -enable-inlining -Hkeep-all-bodies

all: xor

%: %.d
	$(CC) $(CFLAGS) -o $@ $<
	strip $@

clean:
	rm xor
