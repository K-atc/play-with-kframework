BIN=simple-bof oob-read
CC=gcc
AFLCC=afl-gcc
KCC=kcc
CFLAGS=-O0 -Wno-unused-result
TARGETS=$(BIN) $(BIN:%=%.afl) $(BIN:%=%.kcc)

all: $(TARGETS)
	@### Do Nothing

test: $(TARGETS)
	@echo === [simple-bof] ===
	cat fuzz/simple-bof/normal-00.input | ./simple-bof
	-cat pov/simple-bof.input | ./simple-bof
	@echo 
	@echo === [oob-read] ===
	./oob-read.kcc 4

%: %.c
	$(CC) $(CFLAGS) -o $@ $^

%.afl: %.c
	$(AFLCC) $(CFLAGS) -o $@ $^

%.kcc: %.c
	$(KCC) $(CFLAGS) -o $@ $^

clean: 
	rm -f $(TARGETS)
