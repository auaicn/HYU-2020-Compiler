/****************************************************/
/* File: util.c                                     */
/* Utility function implementation                  */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "util.h"

/* Procedure printToken prints a token 
 * and its lexeme to the listing file
 */

// for all tokens
void printToken( TokenType token, const char* tokenString )
{ switch (token)
  { 
    // 6 reserved cases
    case IF:
    case ELSE:
    case WHILE:
    case INT:
    case VOID:
    case RETURN:
      fprintf(listing,
         "reserved word: %s\n",tokenString);
      break;

    // case ASSIGN: fprintf(listing,":=\n"); break;
    case ASSIGN: fprintf(listing,"=\n"); break;
    case EQ: fprintf(listing,"==\n"); break;
    case NE: fprintf(listing,"!=\n"); break;
    case LT: fprintf(listing,"<\n"); break;
    case LE: fprintf(listing,"<=\n"); break;
    case GT: fprintf(listing,">\n"); break;
    case GE: fprintf(listing,">=\n"); break;

    // case EQ: fprintf(listing,"=\n"); break;
    case LPAREN: fprintf(listing,"(\n"); break;
    case RPAREN: fprintf(listing,")\n"); break;
    case LCURLY: fprintf(listing,"{\n"); break;
    case RCURLY: fprintf(listing,"}\n"); break;
    case LBRACE: fprintf(listing,"[\n"); break;
    case RBRACE: fprintf(listing,"]\n"); break;

    // basic operations
    case PLUS: fprintf(listing,"+\n"); break;
    case MINUS: fprintf(listing,"-\n"); break;
    case TIMES: fprintf(listing,"*\n"); break;
    case OVER: fprintf(listing,"/\n"); break;

    // other tokens
    case SEMI: fprintf(listing,";\n"); break;
    case COMMA: fprintf(listing,",\n"); break;
    case ENDFILE: fprintf(listing,"EOF\n"); break;
    case NUM:
      fprintf(listing,
          "NUM, val= %s\n",tokenString);
      break;
    case ID:
      fprintf(listing,
          "ID, name= %s\n",tokenString);
      break;
    case ERROR:
      fprintf(listing,
          "ERROR: %s\n",tokenString);
      break;
    default: /* should never happen */
      fprintf(listing,"Unknown token: %d\n",token);
  }
}

void printTreeNode(TreeNode* node){
  if(node != NULL){
    printf("Node Info\n");
    printf("line no : %d\n", node->lineno);
    printf("Node Kind : %d\n", node->nodekind);
    printf("type : %d\n", node->type);

    int i;

    i=0;
    TreeNode* track = node;
    while(track != NULL){
      track = node->sibling;
      i++;
    }
    printf("num sibling : %d\n", i);


    for (i=0;i<MAXCHILDREN;i++){
      printf("%d\n",i);
      if(node->child[i] == NULL)
        break;
    }
    printf("num child : %d\n", i);


  }else
    printf("Node Pointer (null)\n");
}

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = Stmt;
    t->kind.stmt = kind;
    t->lineno = lineno;
  }
  return t;
}

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = Exp;
    t->kind.exp = kind;
    t->lineno = lineno;
    t->Dtype = Var;
    t->type = Void;
  }
  return t;
}

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char * copyString(char * s)
{ int n;
  char * t;
  if (s==NULL) return NULL;
  n = strlen(s)+1;
  t = malloc(n);
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else strcpy(t,s);
  return t;
}

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static int indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/* printSpaces indents by printing spaces */
static void printSpaces(void)
{ int i;
  for (i=0;i<indentno;i++)
    fprintf(listing," ");
}

/* procedure printTree prints a syntax tree to the 
 * listing file using indentation to indicate subtrees
 */

char str_int[] = {"Integer"};
char str_void[] = {"Void"};

char* type_conv(int type){
  if(type == Integer)
    return str_int;
  else
    return str_void;
}

void printTree( TreeNode * tree )
{ int i;
  INDENT;
  while (tree != NULL) {
    printSpaces();
    if (tree->nodekind == Stmt)
    { switch (tree->kind.stmt) {
        case IfS:
          if(tree->child[2]!= NULL)
            fprintf(listing,"If (condition) (body) (else)\n");
          else
            fprintf(listing,"If (condition) (body)\n");
          break;
        case WhileS:
          fprintf(listing,"While (condition) (body)\n");
          break;
        case ReturnS:
          fprintf(listing,"Return\n");
          break;
        case CompoundS:
          fprintf(listing,"Compound statement\n");
          break;
        case DeclareS:
          switch (tree -> Dtype){
          //typedef enum {Var,Array,Func} DecType;
            case Var:
              fprintf(listing,"Var declaration, name : %s, Type : %s\n", tree->attr.name, type_conv(tree->type));
              break;
            case Array:
              fprintf(listing,"Array declaration, name : %s, Element Type : %s number of elements below\n", tree->attr.name, type_conv(tree->type));
              break; 
            case Func:
              fprintf(listing,"Function declaration, name : %s, return type : %s\n", tree->attr.name, type_conv(tree->type));
              break;
            default:
              fprintf(listing,"Declare Type Unknown Error\n");
              break;
          }
          break;
        default:
          fprintf(listing,"Unknown ExpNode kind\n");
          break;
      }
    }
    else if (tree->nodekind == Exp)
    { switch (tree->kind.exp) {
        case CallE:
          fprintf(listing,"Func call named \"%s\"", tree->attr.name);
          if(tree->child[0])
            fprintf(listing,", with arguments below");
          fprintf(listing, "\n");
          break;
        case OpE:
          if(tree->attr.op == ASSIGN)
            fprintf(listing,"Assign : (destination) (source)\n");
          else{
            fprintf(listing,"Operator : ");
            printToken(tree->attr.op,"\0");
          }
          break;
        case ConstE:
          if(tree->type == Void)
            ;
          else
            fprintf(listing,"Const : %d\n",tree->attr.val); 
          break;
        case IdE:
          switch (tree -> Dtype){
          //typedef enum {Var,Array,Func} DecType;
            case Var:
              fprintf(listing,"Var named \"%s\"\n",tree->attr.name);
              break;
            case Array:
              fprintf(listing,"Value in Array named \"%s\" with index below\n",tree->attr.name);
              break; 
            default:
              fprintf(listing,"Var Or Array?\n");
              break;
          }
          // fprintf(listing,"Id : %s\n",tree->attr.name);
          break;
        case ParamE:
          fprintf(listing,"Single parameter, name : %s, type : %s\n", tree->attr.name, type_conv(tree->type));
          break;          
        default:
          fprintf(listing,"Unknown ExpNode kind\n");
          break;
      }
    }
    else fprintf(listing,"Unknown node kind\n");
    for (i=0;i<MAXCHILDREN;i++)
         printTree(tree->child[i]);
    tree = tree->sibling;
  }
  UNINDENT;
}
