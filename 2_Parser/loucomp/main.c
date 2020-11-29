/****************************************************/
/* File: main.c                                     */
/* Main program for TINY compiler                   */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"

// It's for project 2 parser
// So, set scanner-only false and parser-only flag to be true

/* set NO_PARSE to TRUE to get a scanner-only compiler */
#define NO_PARSE (FALSE)

/* set NO_ANALYZE to TRUE to get a parser-only compiler */
#define NO_ANALYZE (TRUE)

/* set NO_CODE to TRUE to get a compiler that does not
 * generate code
 */
#define NO_CODE (TRUE)

#include "util.h"
#if NO_PARSE
#include "scan.h"
#else
#include "parse.h"
#if !NO_ANALYZE
#include "analyze.h"
#if !NO_CODE
#include "cgen.h"
#endif
#endif
#endif

/* allocate global variables */
int lineno = 0;
FILE * source;
FILE * listing;
FILE * code;

/* allocate and set tracing flags */

// To print only Syntax Tree

int EchoSource = FALSE;
int TraceScan = TRUE;
int TraceParse = TRUE;
int TraceAnalyze = FALSE;
int TraceCode = FALSE;

int Error = FALSE;

int main( int argc, char * argv[] )
// main( int argc, char * argv[] )
{ TreeNode * syntaxTree;
  char pgm[120]; /* source code file name */

  // detect incorrect commandline execution
  if (argc != 2)
    { fprintf(stderr,"usage: %s <filename>\n",argv[0]);
      exit(1);
    }

  // input stream
  strcpy(pgm,argv[1]) ;
  if (strchr (pgm, '.') == NULL)
     strcat(pgm,".tny");

  // read for read-only mode
  source = fopen(pgm,"r");
  if (source==NULL)
  { 
    // open error
    fprintf(stderr,"File %s not found\n",pgm);
    exit(1);
  }

  // it we need file, we may use indirection. > 
  listing = stdout; /* send listing to screen */
  fprintf(listing,"\nC-MINUS COMPILATION: %s\n",pgm);

#if NO_PARSE
  // no PARSE then just get token until we reach to the end of file.
  while (getToken()!=ENDFILE);
#else
  syntaxTree = parse();
  if (TraceParse) {
    fprintf(listing,"\nSyntax tree:\n");
    printTree(syntaxTree);
  }
#if !NO_ANALYZE
  if (! Error)
  { if (TraceAnalyze) fprintf(listing,"\nBuilding Symbol Table...\n");
    buildSymtab(syntaxTree);
    if (TraceAnalyze) fprintf(listing,"\nChecking Types...\n");
    typeCheck(syntaxTree);
    if (TraceAnalyze) fprintf(listing,"\nType Checking Finished\n");
  }
#if !NO_CODE
  if (! Error)
  { char * codefile;
    int fnlen = strcspn(pgm,".");
    codefile = (char *) calloc(fnlen+4, sizeof(char));
    strncpy(codefile,pgm,fnlen);
    strcat(codefile,".tm");
    code = fopen(codefile,"w");
    if (code == NULL)
    { printf("Unable to open %s\n",codefile);
      exit(1);
    }
    codeGen(syntaxTree,codefile);
    fclose(code);
  }
#endif
#endif
#endif
  fclose(source);
  return 0;
}

