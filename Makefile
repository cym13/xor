CC=ldmd
CFLAGS=-release -O -inline

all: xor

%: %.d
	$(CC) $(CFLAGS) $<
	strip $@

clean:
	rm xor *.o
