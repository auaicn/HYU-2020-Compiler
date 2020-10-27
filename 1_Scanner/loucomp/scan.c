/****************************************************/
/* File: scan.c                                     */
/* The scanner implementation for the TINY compiler */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "util.h"
#include "scan.h"

/* states in scanner DFA */
// typedef enum
//    { START,INASSIGN,INCOMMENT,INNUM,INID,DONE }
//    StateType;


// below changed by own
typedef enum
   { START,INEQ,INCOMMENT,INNUM,INID,DONE,INLT,INGT,INOVER,INCOMMENT_,INAS,INNE }
   StateType;

/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];

/* BUFLEN = length of the input buffer for
   source code lines */
#define BUFLEN 256

static char lineBuf[BUFLEN]; /* holds the current line */
static int linepos = 0; /* current position in LineBuf */
static int bufsize = 0; /* current size of buffer string */
static int EOF_flag = FALSE; /* corrects ungetNextChar behavior on EOF */

/* getNextChar fetches the next non-blank character
   from lineBuf, reading in a new line if lineBuf is
   exhausted */
// above description is somewhat incorrect.
static int getNextChar(void)
{ if (!(linepos < bufsize))
  { lineno++;
    if (fgets(lineBuf,BUFLEN-1,source))
    { if (EchoSource) 
      // oscreen. original one line printing is by here.
      fprintf(listing,"%4d: %s",lineno,lineBuf);
      bufsize = strlen(lineBuf);
      linepos = 0;
      return lineBuf[linepos++];
    }
    else
    { EOF_flag = TRUE;
      return EOF;
    }
  }
  // here we should not wipe out white spaces.
  // then we cannot seperate "/ *" from "/*"
  else 
    {
      printf("linepos : %d\n",linepos);
      return lineBuf[linepos++];
    }
}

/* ungetNextChar backtracks one character
   in lineBuf */
static void ungetNextChar(void)
{ if (!EOF_flag) linepos-- ;}

/* lookup table of reserved words */
static struct
    { char* str;
      TokenType tok;
    } reservedWords[MAXRESERVED]

   = {{"if",IF},
      {"else",ELSE},
      {"while",WHILE},
      {"return",RETURN},
      {"void",VOID},
      {"int",INT}};

/* lookup an identifier to see if it is a reserved word */
/* uses linear search */
static TokenType reservedLookup (char * s)
{ int i;
  for (i=0;i<MAXRESERVED;i++)
    if (!strcmp(s,reservedWords[i].str))
      return reservedWords[i].tok;
  return ID;
}

/****************************************/
/* the primary function of the scanner  */
/****************************************/
/* function getToken returns the 
 * next token in source file
 */
TokenType getToken(void)
{  /* index for storing into tokenString */
  int tokenStringIndex = 0;
  /* holds current token to be returned */
  TokenType currentToken;
  /* current state - always begins at START */
  StateType state = START;
  /* flag to indicate save to tokenString */
  int save;
  while (state != DONE)
  { 

    // get not-white-space character
    int c = getNextChar();
    
    save = TRUE;

    int t = 100000000;
    while(t--);

    switch (state)
    { 
      case START:
        if (isdigit(c)){
          currentToken = NUM;
          state = INNUM;
          break;
        }
        else if (isalpha(c)){
          currentToken = ID;
          state = INID;
          break;
        }
        else if ((c == ' ') || (c == '\t') || (c == '\n')){
          save = FALSE;
          break;
        }
        else
        { 
          save = TRUE;
          state = DONE; // important. here, base setting has done.
          switch (c)
          { 
            case EOF: // important. EOF condition always matters.
              save = FALSE;
              currentToken = ENDFILE;
              break;

            /* currentToken not yet decided */
            // again, excluded / /*    < <=    > >=    = ==
            // specifically, we should classify ! with != , also for * and */
            // */ is.... longer than * and / itself, 
            // also an undinable token.
            case '=':
              // ASSIGN EQ available
              currentToken = ASSIGN;
              state = INEQ;
              break;
            case '<':
              // LT LE available
              currentToken = LT;
              state = INLT;
              break;
            case '>':
              // GT GE available
              currentToken = GT;
              state = INGT;
              break;
            case '/':
              // comment, div available
              currentToken = OVER;
              state = INOVER;
              break;

            case '*':
              currentToken = TIMES;
              state = INAS;
              break;
            case '!':
              currentToken = ERROR;
              state = INNE;
              break;

            // included + -  * [] {} () , ;  != */ num letter 
            // basic operation
            case '+':
              currentToken = PLUS;
              break;
            case '-':
              currentToken = MINUS;
              break;

            // semicolon and comma
            case ';':
              currentToken = SEMI;
              break;
            case ',':
              currentToken = COMMA;
              break;

            // parentheses
            case '(':
              currentToken = LPAREN;
              break;
            case ')':
              currentToken = RPAREN;
              break;
            case '{':
              currentToken = LCURLY;
              break;
            case '}':
              currentToken = RCURLY;
              break;
            case '[':
              currentToken = LBRACE;
              break;
            case ']':
              currentToken = RBRACE;
              break;

            // not correspond to any token  
            default:
              currentToken = ERROR;
              break;
          }
          break;
        }
        // break;

      case INNUM:
        if (isdigit(c));
          // state = INNUM;
        else{
          save = FALSE;
          // ungetNextChar();
        }
        break;

      case INID:
        if (isalpha(c));
        else{
          save = FALSE;
          // ungetNextChar();
        }
        break;

      case INOVER:
        if(c == '*')
          state = INCOMMENT;
        else{
          save = FALSE;
          // ungetNextChar();
          state = DONE;
        }
        break;

      case INCOMMENT:
        if(c == '*')
          state = INCOMMENT_;

      case INCOMMENT_:
        if(c == '/')
          state = DONE;
        else if (c == '*')
          state = INCOMMENT_;
        else 
          state = INCOMMENT;

      case INLT:
        if(c == '=')
          currentToken = LE;
        else{
          currentToken = LT;
          save = FALSE;
          ungetNextChar();
        }
        break;

      case INGT: // > Greater than
        if(c == '=')
          currentToken = GE;
        else{
          currentToken = GT;
          save = FALSE;
          ungetNextChar();
        }
        state = DONE;
        break;

      case INEQ:
        if(c == '=')
          currentToken = EQ;
        else
          currentToken = ASSIGN;
        break;

      case INNE:
        if(c == '=')
          currentToken = NE;
        else
          currentToken = ERROR;
        break;

      case DONE:
      default: /* should never happen */
        fprintf(listing,"Scanner Bug: state= %d\n",state);
        state = DONE;
        currentToken = ERROR;
        break;
    }
  }
  // token may be too long 
  // even though, no error is catched.
  // only preceding 40 characters are saved and printed.

  if ((save) && (tokenStringIndex <= MAXTOKENLEN))
    tokenString[tokenStringIndex++] = (char) c;
  
  if (state == DONE){
    if (currentToken == ID)
    { 
      tokenString[tokenStringIndex] = '\0';
      currentToken = reservedLookup(tokenString);
    }
  }
}

  // if trace option was turned on
  // print out token to one line.
  // here's the reason why 'tokenString' variable is not 2-d array.
  // here print is executed and 'tokenString' is reused every getToken() call.
  if (TraceScan) {
    fprintf(listing,"\t%d: ",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
} /* end getToken */

