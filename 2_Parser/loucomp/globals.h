/****************************************************/
/* File: globals.h                                  */
/* Yacc/Bison Version                               */
/* Global types and vars for TINY compiler          */
/* must come before other include files             */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

/* Yacc/Bison generates internally its own values
 * for the tokens. Other files can access these values
 * by including the tab.h file generated using the
 * Yacc/Bison option -d ("generate header")
 *
 * The YYPARSER flag prevents inclusion of the tab.h
 * into the Yacc/Bison output itself
 */

#ifndef YYPARSER

/* the name of the following file may change */
#include "y.tab.h"

/* ENDFILE is implicitly defined by Yacc/Bison,
 * and not included in the tab.h file
 */
#define ENDFILE 0

#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

/* MAXRESERVED = the number of reserved words */
#define MAXRESERVED 8

/* Yacc/Bison generates its own integer values
 * for tokens
 */
typedef int TokenType; 

extern FILE* source; /* source code text file */
extern FILE* listing; /* listing output text file */
extern FILE* code; /* code text file for TM simulator */

extern int lineno; /* source line number for listing */

/**************************************************/
/***********   Syntax tree for parsing ************/
/**************************************************/

// Tree Node Kind : Statement or Expression
// 이 모든 타입들은, 타입을 나눠줘야하는지는, 구현하면서 필요에따라서 해야할듯?
typedef enum {Stmt,Exp} NodeKind;

// undefined 는 알아서 쳐내준다. error state 로, syntax error 보낸다.
// Statement Node Kind
// IF statement Kotlin 처럼 IF 문이 expression 인게 아님.
// ELSE statement
// Compound Statement 등등등

typedef enum {
    IfS,
    DeclareS,
    AssignS, 
    WhileS,
    ReturnS,
    CompoundS,
    ExpressionS
} StmtKind;

typedef enum {
    OpE,
    ConstE,
    IdE,
    TypeE,
    VarE,
    ParamE,
    CallE
} ExpKind;

typedef enum {Void,Integer} ExpType;
typedef enum {Var,Array,Func} DecType;

#define MAXCHILDREN 3

typedef struct treeNode{

    struct treeNode * child[MAXCHILDREN];
    struct treeNode * sibling;
    int lineno;

     //yacc sets automatically these two when calling newexpnide(??k)
    NodeKind nodekind;
    union { 
        StmtKind stmt; 
        ExpKind exp;
    } kind;

    union { 
        TokenType op;
        int val;
        char * name; 
    } attr;

    /* for type checking of exps */
    ExpType type;
    DecType Dtype;

} TreeNode;

/**************************************************/
/***********   Flags for tracing       ************/
/**************************************************/

/* EchoSource = TRUE causes the source program to
 * be echoed to the listing file with line numbers
 * during parsing
 */
extern int EchoSource;

/* TraceScan = TRUE causes token information to be
 * printed to the listing file as each token is
 * recognized by the scanner
 */
extern int TraceScan;

/* TraceParse = TRUE causes the syntax tree to be
 * printed to the listing file in linearized form
 * (using indents for children)
 */
extern int TraceParse;

/* TraceAnalyze = TRUE causes symbol table inserts
 * and lookups to be reported to the listing file
 */
extern int TraceAnalyze;

/* TraceCode = TRUE causes comments to be written
 * to the TM code file as code is generated
 */
extern int TraceCode;

/* Error = TRUE prevents further passes if an error occurs */
extern int Error; 
#endif
