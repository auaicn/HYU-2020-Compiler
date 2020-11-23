/****************************************************/
/* File: cminus.y                                   */
/* The CMINUS Yacc/Bison specification file         */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */

%}

%token ENDFILE
%token IF ELSE WHILE INT VOID RETURN
%token ID NUM
%token PLUS MINUS TIMES OVER
%token EQ NE LT LE GT GE
%token LPAREN RPAREN LBRACE RBRACE LCURLY RCURLY
%token ASSIGN SEMI COMMA
%token ERROR

/*
%token IF THEN ELSE END REPEAT UNTIL READ WRITE
%token ID NUM 
%token ASSIGN EQ LT PLUS MINUS TIMES OVER LPAREN RPAREN SEMI
%token ERROR 
*/

%% /* Grammar for CMINUS, Rules with BNF syntax*/

program           : declaration_list
                    { 
                      savedTree = $1;
                    } 

declaration_list  : declaration_list declaration 
                  | declaration
declaration       : var_declaration 
                  | fun_declaration
var_declaration   : type_specifier ID SEMI
                  | type_specifier ID LBRACE NUM RBRACE SEMI
type_specifier    : INT 
                  | VOID
fun_declaration   : type_specifier ID LPAREN params RPAREN compound_stmt
params            : param_list 
                  | VOID
param_list        : param_list COMMA param
                  | param
param             : type_specifier ID 
                  | type_specifier ID LBRACE RBRACE SEMI
compound_stmt     : LCURLY local_declarations statement_list RCURLY

local_declarations: local_declarations var_declaration 
                  // | empty



statement_list    : statement_list statement 
                  // | empty
statement         : expression_stmt 
                  | compound_stmt 
                  | selection_stmt 
                  | iteration_stmt 
                  | return_stmt
expression_stmt   : expression SEMI
                  | SEMI
selection_stmt    : IF LPAREN expression RPAREN statement
                  | IF LPAREN expression RPAREN statement ELSE statement
iteration_stmt    : WHILE LPAREN expression RPAREN statement
return_stmt       : RETURN SEMI
                  | RETURN expression SEMI
expression        : var ASSIGN expression
                  | simple_expression
var               : ID
                  | ID LBRACE expression RBRACE
simple_expression : additive_expression relop additive_expression
                  | additive_expression
relop             : LT
                  | LE
                  | GT
                  | GE
                  | EQ
                  | NE




additive_expression   : additive_expression addop term
                      | term  
addop             : PLUS
                  | MINUS
term              : term mulop factor 
                  | factor
mulop             : TIMES
                  | OVER
factor            : LPAREN expression RPAREN
                  | var
                  | call
                  | NUM
call              : ID LPAREN args RPAREN
args              : arg_list
                  // | empty
arg_list          : arg_list COMMA expression
                  | expression


/*

program     : stmt_seq
            ;
stmt_seq    : stmt_seq SEMI stmt
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t_>sibling != NULL)
                        t = t_>sibling;
                     t_>sibling = $3;
                     $$ = $1; }
                     else $$ = $3;
                 }
            | stmt  { $$ = $1; }
            ;
stmt        : if_stmt { $$ = $1; }
            | repeat_stmt { $$ = $1; }
            | assign_stmt { $$ = $1; }
            | read_stmt { $$ = $1; }
            | write_stmt { $$ = $1; }
            | error  { $$ = NULL; }
            ;

// all tokens, symbols 
if_stmt     : IF exp THEN stmt_seq END
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $2;
                   $$->child[1] = $4;
                 }
            | IF exp THEN stmt_seq ELSE stmt_seq END
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $2;
                   $$->child[1] = $4;
                   $$->child[2] = $6;
                 }
            ;
repeat_stmt : REPEAT stmt_seq UNTIL exp
                 { $$ = newStmtNode(RepeatK);
                   $$->child[0] = $2;
                   $$->child[1] = $4;
                 }
            ;
assign_stmt : ID { savedName = copyString(tokenString);
                   savedLineNo = lineno; }
              ASSIGN exp
                 { $$ = newStmtNode(AssignK);
                   $$->child[0] = $4;
                   $$->attr.name = savedName;
                   $$->lineno = savedLineNo;
                 }
            ;
read_stmt   : READ ID
                 { $$ = newStmtNode(ReadK);
                   $$->attr.name =
                     copyString(tokenString);
                 }
            ;
write_stmt  : WRITE exp
                 { $$ = newStmtNode(WriteK);
                   $$->child[0] = $2;
                 }
            ;
exp         : simple_exp LT simple_exp 
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = LT;
                 }
            | simple_exp EQ simple_exp
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = EQ;
                 }
            | simple_exp { $$ = $1; }
            ;
simple_exp  : simple_exp PLUS term 
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = PLUS;
                 }
            | simple_exp MINUS term
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = MINUS;
                 } 
            | term { $$ = $1; }
            ;
term        : term TIMES factor 
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = TIMES;
                 }
            | term OVER factor
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = OVER;
                 }
            | factor { $$ = $1; }
            ;
factor      : LPAREN exp RPAREN
                 { $$ = $2; }
            | NUM
                 { $$ = newExpNode(ConstK);
                   $$->attr.val = atoi(tokenString);
                 }
            | ID { $$ = newExpNode(IdK);
                   $$->attr.name =
                         copyString(tokenString);
                 }
            | error { $$ = NULL; }
            ;

*/

/*
do not add anything under here.
Here code analyzes Def and Rules scripted above.
*/
%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}

