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
%expect 1
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
                          // recycle type_specifier Node
                          $$ = $1;

                          // Expression to Statement
                          $$ -> nodekind = Stmt; 

                          // Set Statement Type
                          $$ -> kind.stmt = DeclareS;

                          // Set Declare Type
                          $$ -> Dtype = Var;

                          // cpy name from identifier Node
                          $$ -> attr.name = $2 -> attr.name;

                        }
                  | type_specifier identifier LBRACE constint RBRACE SEMI
                        {
                          // recycle type_specifier Node
                          $$ = $1;

                          // Expression to Statement
                          $$ -> nodekind = Stmt; 

                          // Set Statement Type
                          $$ -> kind.stmt = DeclareS;

                          // Set Declare Type
                          $$ -> Dtype = Array;

                          // cpy name from identifier Node
                          $$ -> attr.name = $2 -> attr.name;

                          // Set Number of Elements
                          // $$ -> child[0] = $4;
                          $$ -> child[0] = newExpNode(ConstE);
                          $$ -> child[0] -> type = Integer;
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
                        // not important
                        $$ = newStmtNode(ReturnS); 
                        $$ -> type = Void;
                      }
                  | RETURN expression SEMI
                      {
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
                        {
                          // printf("var made with identifier\n");
                          $$ = $1; }
                  | identifier LBRACE expression RBRACE
                        {
                          // recycle $1
                          $$ = $1;

                          // set Declare type
                          $$ -> Dtype = Array;

                          // set child
                          $$ -> child[0] = $3;
                        }
                  ;

identifier        : ID
                        {
                          $$ = newExpNode(IdE);
                          $$ -> attr.name = copyString(idString);
                        }
                  ;

constint          : NUM
                        {
                          // printf("constant\n");
                          $$ = newExpNode(ConstE);
                          $$ -> type = Integer;
                          $$ -> attr.val = atoi(numString);
                        }
                  ;

simple_expression : additive_expression relop additive_expression
                        { 
                          $$ = newExpNode(OpE);
                          $$->child[0] = $1;
                          $$->child[1] = $3;
                          $$->attr.op = $2->attr.op;
                        }
                  | additive_expression 
                        { 
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
                        { $$ = $1; }
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
                        { $$ = $2; }
                  | var
                        { $$ = $1; }
                  | call
                        { $$ = $1; }
                  | constint
                        { $$ = $1; }
                  ;
call              : identifier LPAREN args RPAREN
                        { 
                          // recycle id node
                          $$ = $1;

                          // set Expression Type
                          $$ -> kind.exp = CallE;

                          // Even thouhg there could be no argument
                          // Example says 
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
                  ;
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

