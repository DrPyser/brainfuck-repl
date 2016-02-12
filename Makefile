
AS=gcc -o
RM=rm -f

# Point d'entrée principal
all: brainfuck-repl

# Comment construire "ch".
brainfuck-repl: brainfuck.s stdio.s
	$(AS) brainfuck-repl brainfuck.s stdio.s
clean:
	$(RM) brainfuck-repl *.o 

