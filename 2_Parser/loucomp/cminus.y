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

static int yylex();
static int yyerror(char * message);

%}

%token IF ELSE WHILE INT VOID RETURN
%token ID NUM
%token PLUS MINUS TIMES OVER
%token EQ NE LT LE GT GE
%token LPAREN RPAREN LBRACE RBRACE LCURLY RCURLY
%token ASSIGN SEMI COMMA
%token ERROR

%% /* Grammar for CMINUS, Rules with BNF syntax*/

program           : declaration_list
                        { savedTree = $1;} 
                  ;
declaration_list  : declaration_list declaration
                        {
                          TreeNode* track = $1;
                          if(track != NULL){
                            while(track -> sibling != NULL)
                              track = track -> sibling;
                            track -> sibling = $2;
                            $$ = $1;
                          }else
                            $$ = $2;
                        } 
                  | declaration
                        { $$ = $1;} 
                  ;  
declaration       : var_declaration 
                        { $$ = $1;} 
                  | fun_declaration
                        { $$ = $1;} 
                  ;
var_declaration   : type_specifier identifier SEMI
                        {
                          $$ = $1;

                          $$ -> nodekind = Stmt; // type need not to be treated
                          $$ -> kind.stmt = DeclareS;
                          $$ -> Dtype = Array;

                          $$ -> attr.name = $2 -> attr.name;
                          $$ = $1; // type need not to be treated
                        }
                  | type_specifier identifier LBRACE NUM RBRACE SEMI
                        {
                          printf("array creadted\n");
                          $$ = $1;

                          $$ -> nodekind = Stmt; // type need not to be treated
                          $$ -> kind.stmt = DeclareS;
                          $$ -> Dtype = Array;

                          $$ -> attr.name = $2 -> attr.name;

                          // number of element
                          $$ -> child[0] = newExpNode(ConstE);
                          $$ -> child[0] -> attr.val = atoi(numString);
                        }
                  ;
type_specifier    : INT 
                        {
                          $$ = newExpNode(TypeE);
                          $$ -> type = Integer;
                        }
                  | VOID
                        {
                          $$ = newExpNode(TypeE);
                          $$ -> type = Void;
                        }
                  ;
fun_declaration   : type_specifier identifier LPAREN params RPAREN compound_stmt
                        {
                          $$ = $1;
                          $$ -> nodekind = Stmt;
                          $$ -> kind.stmt = DeclareS;
                          $$ -> Dtype = Func;
                          $$ -> attr.name = $2->attr.name;

                          $$ -> child[0] = $4; // params
                          $$ -> child[1] = $6; // compound state ment
                        }
                  ;
params            : param_list 
                        { $$ = $1; }
                  | VOID
                        { 
                          printf("empty paramaters\n");
                          // it has entry
                          $$ = newExpNode(ParamE);
                          $$ -> type = Void;
                          $$ -> attr.name = "(null)";
                        }
                  ;
param_list        : param_list COMMA param
                        {
                          TreeNode* track = $1;
                          if(track != NULL){
                            while(track -> sibling != NULL)
                              track = track -> sibling;
                            track->sibling = $3; // COMMA 넘어가구
                          }
                          else
                            $$ = $3;
                        } 
                  | param
                        { $$ = $1; }
                  ;
param             : type_specifier identifier 
                        {
                          $1 -> attr.name = $2 -> attr.name;
                          $1 -> kind.exp = ParamE; // already Exp, detailed category changed here.
                          // $1 -> kind.exp = ParamE;
                          // send to parent
                          $$ = $1;
                        }
                  | type_specifier identifier LBRACE RBRACE
                        {
                          // Array Input as argument
                          // Only for Parser project, it doesn't matters.
                          // Data we have is only ID and it's type.

                          $1 -> attr.name = $2 -> attr.name;
                          $1 -> kind.exp = IdE;
                          $$ = $1;
                        }
                  ;

compound_stmt     : LCURLY local_declarations statement_list RCURLY
                        {
                          // statements follow multiple local_declarations.
                          // treating as sibling as possible I think. -> NO
                          // because there is some indent on given Example 

                          $$ = newStmtNode(CompoundS);
                          if($2==NULL){
                            $$ -> child[0] = $3;
                          }else{
                            $$ -> child[0] = $2;
                            $$ -> child[1] = $3;
                          }
                        }
                  ;
local_declarations: local_declarations var_declaration 
                        // multiple local_declarations
                        {
                          TreeNode* track = $1;
                          if(track != NULL){
                            while(track -> sibling != NULL)
                              track = track -> sibling;
                            track -> sibling = $2;
                            $$ = $1;
                          }else
                            $$ = $2;
                        } 
                  |
                        { 
                          // nothing to reference. set local_declarations to be NULL explicitly
                          $$ = NULL; 
                        }
                  ;
statement_list    : statement_list statement 
                        {
                          TreeNode* track = $1;
                          if(track != NULL){
                            while(track -> sibling != NULL)
                              track = track -> sibling;
                            track -> sibling = $2;
                            $$ = $1;
                          }else
                            $$ = $2;
                        } 
                  |
                        { 
                          // nothing to reference. set statement_list to be NULL explicitly
                          $$ = NULL; 
                        }
                  ;
statement         : expression_stmt 
                        { $$ = $1; }
                  | compound_stmt 
                        { $$ = $1; }
                  | selection_stmt 
                        { $$ = $1; }
                  | iteration_stmt 
                        { $$ = $1; }
                  | return_stmt
                        { $$ = $1; }
                  ;
expression_stmt   : expression SEMI
                        { $$ = $1; }
                  | SEMI
                        { $$ = NULL; }
                  ;
selection_stmt    : IF LPAREN expression RPAREN statement
                        { 
                          $$ = newStmtNode(IfS);
                          $$->child[0] = $3;
                          $$->child[1] = $5;
                        }
                  | IF LPAREN expression RPAREN statement ELSE statement
                        { 
                          $$ = newStmtNode(IfS);
                          $$->child[0] = $3;
                          $$->child[1] = $5;
                          $$->child[2] = $7;
                        }
                  ;
iteration_stmt    : WHILE LPAREN expression RPAREN statement
                        { 
                          $$ = newStmtNode(WhileS);
                          $$->child[0] = $3;
                          $$->child[1] = $5;
                        }
                  ;
return_stmt       : RETURN SEMI
                      {
                        $$ = newStmtNode(ReturnS); 
                        $$ -> type = Void;
                      }
                  | RETURN expression SEMI
                      {
                        printf("return with expression");
                        $$ = newStmtNode(ReturnS); 
                        $$ -> type = Integer;
                        $$ -> child[0] = $2;
                      }
                  ;
expression        : var ASSIGN expression
                        {
                          $$ = newExpNode(OpE);
                          $$->attr.op = ASSIGN;    
                          $$->child[0] = $1;
                          $$->child[1] = $3;
                        }                  
                  | simple_expression
                        { 
                          $$ = $1; 
                        }
                  ;
var               : identifier
                        { $$ = $1; }
                  | identifier LBRACE expression RBRACE
                        {
                          $1 -> child[0] = $3;
                          $$ = $1;
                        }
                  ;

identifier        : ID
                        {
                          $$ = newExpNode(IdE);
                          $$ -> attr.name = copyString(idString);
                        }
                  ;

simple_expression : additive_expression relop additive_expression
                        { 
                          printf("making simple_expression\n");
                          $$ = newExpNode(OpE);
                          $$->child[0] = $1;
                          $$->child[1] = $3;
                          $$->attr.op = $2->attr.op;
                        }
                  | additive_expression 
                        { 
                          printf("simple_expression\n");
                          $$ = $1;
                        }
                  ;
relop             : LT
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = LT;
                        }
                  | LE
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = LE;
                        }
                  | GT
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = GT;
                        }
                  | GE
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = GE;
                        }
                  | EQ
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = EQ;
                        }
                  | NE
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = NE;
                        }
                  ;

additive_expression   
                  : additive_expression addop term
                        {
                          $$ = newExpNode(OpE);
                          $$->child[0] = $1;
                          $$->child[1] = $3;
                          $$->attr.op = $2->attr.op;
                        }
                  | term  
                        { 
                          $$ = $1; 
                        }
                  ;
addop             : PLUS
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = PLUS;
                        }
                  | MINUS
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = MINUS;
                        }
                  ;
term              : term mulop factor 
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = $2 -> attr.op;
                          $$ -> child[0] = $1;
                          $$ -> child[1] = $3;
                        }
                  | factor
                        {
                          $$ = $1;
                        }
                  ;
mulop             : TIMES
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = TIMES;
                        }
                  | OVER
                        { 
                          $$ = newExpNode(OpE);
                          $$ -> attr.op = OVER;
                        }
                  ;
factor            : LPAREN expression RPAREN
                        { 
                          // send expression itself
                          $$ = $2; 
                        }
                  | var
                        { 
                          // var has it's own Exp Node
                          $$ = $1; 
                        }
                  | call
                        { 
                          // call has it's own Exp Node
                          $$ = $1; }
                  | NUM
                        { 
                          $$ = newExpNode(ConstE);
                          $$ -> type = Integer;
                          $$ -> attr.val = atoi(numString);
                        }
                  ;
call              : identifier LPAREN args RPAREN
                        { 
                          $$ = $1;
                          $$ -> kind.exp = CallE;

                          // there could be no argument
                          // then leave first child to have NULL value
                          if($3 != NULL)
                            $$ -> child[0] = $3;
                        }
                  ;
args              : arg_list
                        { $$ = $1; }
                  | 
                        { $$ = NULL; }
                  ;
arg_list          : arg_list COMMA expression
                        {
                          TreeNode* track = $1;
                          if(track != NULL){
                            while(track -> sibling != NULL)
                              track = track -> sibling;
                            track -> sibling = $3;
                            $$ = $1;
                          }else
                            $$ = $3;
                        } 
                  | expression
                        { 
                          $$ = $1; 
                        }

%%

int yyerror(char * message)
{ 
  fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 * not its' own. its from flex
 */

static int yylex(void)
{ 
  return getToken(); 
}

TreeNode * parse(void)
{ 
  yyparse();
  return savedTree;
}

