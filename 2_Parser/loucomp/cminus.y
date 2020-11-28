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
                    { 
                      savedTree = $1;
                    } 

declaration_list  : declaration_list declaration
                    {
                      // 이게 Syntax Tree: 부분이라 생각하면됨.
                      // reduce logic 인데 right associative 하게 해줘야되나?
                      // 여기까지는 tiny를 좀 참고하자
                      // 오른쪽 끝에, sibling 으로 끝까지 포인터 따라 간다음에 append 해준다.
                      TreeNode* track = $1;
                      if(track != NULL){
                        while(track -> sibling != NULL)
                          track = track -> sibling;
                        track -> sibling = $2;
                        $$ = $1; // 필요한가? 당연한걸
                      }else
                        // 이게 가능한 경우인가?
                        // program 에서 끝나는건데,
                        $$ = $2;
                      // $1 -> sibling = $2;
                      // savedTree = $1;
                    } 
                  | declaration
                    {
                      // 처음 declaration 까지 묶이면, declaration list 로 바로 변할듯
                      // 갈데가 없거든, 그런데 그게 바로 program 으로 변하면 안되는데,
                      
                      // declaration 이랑 declaration list 는 다른 Non-terminal 이기 때문에...?
                      $$ = $1; 
                      // 이게 참 해줘야하는 걸까 하나를 하나로 바꾸는 reducing 느낌이네.
                      // 노드가 하나 생성되는 시점은 언제로 하는게 좋을까.
                    } 
declaration       : var_declaration 
                    {
                      // 여기는 그냥 노드 생성안하고 넘어가도 괜찮을듯.
                      $$ = $1;
                    }
                  | fun_declaration
                    {
                      $$ = $1;
                    }
var_declaration   : type_specifier ID SEMI
                    {
                      // child 가 생겨야하니까 할당을 해주는게 좋겠어.
                      // only declaration
                      $$ = newStmtNode(VarDeclareK);
                      // 순서의 상관관계는 나중에 디버깅하면서 맞추자.
                      // ID 를위한 걸 만들어 주는게, 언제인지에 따라서 여기서 할당해도 되고, ID 가 나왓을때 해줘도 되긴하는데,
                      // ID 는 terminal 이라서 지금 해줘야 할 것 같구,
                      // type-spe 은 애매하다. 상관없을듯.

                      $2 = newExpNode(IdK);
                      $2 -> attr.name = $1;
                      $$->child[0] = $2; // ID
                    }
                  | type_specifier ID LBRACE NUM RBRACE SEMI
type_specifier    : INT 
                    {
                      // 이렇게 작성하면, 사실의미가.. 있긴 하지
                      // type_specifier 가 아예 없어도 되는게 되버리는 정도는 아니구,
                      // void 랑 같이 묶여서 reduced 될수 있는 표기니까. 
                      // 아무튼 그냥 올라감. INT 나 VOID 인 경우 둘다!
                      // 그래서 위에서 그냥 $1 이런식으로 받아서 쓸 수 있을것임.
                      $$ = $1;
                    }
                  | VOID
                    {
                      $$ = $1;
                    }
fun_declaration   : type_specifier ID LPAREN params RPAREN compound_stmt
                    {
                      // function 값은 아니기에 statement 로 판단할거긴한데,
                      // 이름은 어디에 넣니? itself 에?
                      
                      // ID 에 하나의 노드를 주어야, 나중에 semantic 할때 한번 스캔으로 분석이 가능하지 않을까 싶은데? ID 는 Exp라고 하자.. IdK 도 있었으니까
                      $2 = newExpNode(IdK);
                      s2 -> attr.name = 
                      $$ -> attr.name = ID;

                      // 이게 Expression 은 아니지만, Exp Type 을 사용 할수 있을 것 같아.
                      $$ -> type = $1;
                      $$ -> child[0] = $2;
                      $$ -> child[1] = $4;
                      $$ -> child[2] = $6;
                    }
params            : param_list 
                    {
                      $$ = $1;
                    }
                  | VOID
                    {
                      // const 값이긴 하잖아. ExpType 에서 VOID 인거 써먹을 곳이 딱 여기네
                      $1 = newExpNode(ConstK);
                      $1 -> type = $1;
                      $$ = $1;
                    }

param_list        : param_list COMMA param
                    {
                      // LALR(1) grammar 는 program 이라는 Non terminal 을 만들어 가는 과정이기때문에
                      // 만들어진다면, param 이 먼저 만들어졌을 것임
                      // param list 는 Null 의 가능 성이 있다.
                      // list 가 있다면, sibling 의 끝에 append 해주자. push_back 느낌.

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
                    {
                      // 처음으로 param 이 마주된 상태 그냥 올려준다
                      $$ = $1;
                    }
param             : type_specifier ID 
                    {
                      // 할당은 위에서 되었으니까 근데 ID 가 있네
                      // 이름이랑 만들어서 넣어주자

                      $ = newExpNode(IdK);
                      $2 -> attr.name = $2;
                      $1 -> attr = 
                      $1 -> child[0] = 
                    }
                  | type_specifier ID LBRACE RBRACE SEMI
compound_stmt     : LCURLY local_declarations statement_list RCURLY
                    // 룰 보아하니 무조건 local 에서는 declared then stated 구나
                    {


                    }
local_declarations: local_declarations var_declaration 
                  |



statement_list    : statement_list statement 
                  |
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
                  | 
arg_list          : arg_list COMMA expression
                  | expression

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

