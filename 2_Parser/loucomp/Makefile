CC = gcc
CFLAGS = 

OBJS = main.o util.o lex.yy.o symtab.o analyze.o code.o cgen.o y.tab.o 

all : cminus 

cminus: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@

lex.yy.c: cminus.l
	flex cminus.l

lex.yy.o: lex.yy.c globals.h y.tab.h util.h scan.h
	$(CC) $(CFLAGS) -c lex.yy.c -lfl

y.tab.c: cminus.y
	yacc -d -v cminus.y

y.tab.h: y.tab.c

y.tab.o: y.tab.c globals.h y.tab.h util.h scan.h parse.h
	$(CC) $(CFLAGS) -c y.tab.c -lfl

globals.h: y.tab.h

main.o: main.c globals.h util.h scan.h parse.h analyze.h cgen.h
	$(CC) $(CFLAGS) -c main.c

util.o: util.c util.h globals.h
	$(CC) $(CFLAGS) -c util.c

symtab.o: symtab.c symtab.h
	$(CC) $(CFLAGS) -c symtab.c

analyze.o: analyze.c globals.h symtab.h analyze.h
	$(CC) $(CFLAGS) -c analyze.c

code.o: code.c code.h globals.h
	$(CC) $(CFLAGS) -c code.c

cgen.o: cgen.c globals.h symtab.h code.h cgen.h
	$(CC) $(CFLAGS) -c cgen.c

clean:
	rm -vf *.o y.tab.c y.tab.h s lex.yy.c y.tab.c y.tab.h cminus
