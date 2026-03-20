# Makefile
cc = ghc
SRC = ast.hs 

.PHONY: all clean

all: $(SRC)
	$(cc) -o ast.exe $(SRC)

run: 
	@./ast.exe

tree:
	$(cc) -o ast_to_tree.exe ast_to_tree.hs
run_tree: ast_to_tree.exe
	@./ast_to_tree.exe 

clean:
	rm -rf *.exe *.o *.hi
