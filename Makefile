
all: xor

%: %.d
	ldmd -release -O -inline $<

clean:
	rm xor *.o
