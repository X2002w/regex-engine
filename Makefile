# Makefile
cc = ghc
SRC = ast.hs 

.PHONY: all clean

all: $(SRC)
	$(cc) -o ast.exe $(SRC)

run: 
	@./ast.exe

clean:
	rm -rf *.exe *.o *.hi
