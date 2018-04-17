CC=gcc
CFLAGS=-O4 -Wall

all: xor

%: %.c
	$(CC) $(CFLAGS) -o $@ $<
	strip $@

clean:
	rm xor
