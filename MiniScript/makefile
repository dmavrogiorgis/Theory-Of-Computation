all: parser flexer
	gcc -o MiniScript lex.yy.c MiniScript.tab.c cgen.c -lfl
parser:
	bison -d -v -r all MiniScript.y	
flexer:
	flex MiniScript.l
bisonOUT:
	gcc -std=c99 -Wall bisonOUT.c
clean:
	rm MiniScript lex.yy.c MiniScript.tab.c MiniScript.tab.h MiniScript.output bisonOUT.c a.out
