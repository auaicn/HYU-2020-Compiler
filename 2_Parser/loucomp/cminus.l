/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for TINY                       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

%option noyywrap
%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
char idString[MAXTOKENLEN+1];
char numString[MAXTOKENLEN+1];

%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \n
whitespace  [ \t]+

%%

"if"            {return IF;}
"else"          {return ELSE;}
"while"         {return WHILE;}
"int"           {return INT;}
"void"          {return VOID;}
"return"        {return RETURN;}
"="             {return ASSIGN;}
"=="            {return EQ;}
"!="            {return NE;}
"<"             {return LT;}
"<="            {return LE;}
">"             {return GT;}
">="            {return GE;}
"+"             {return PLUS;}
"-"             {return MINUS;}
"*"             {return TIMES;}
"/"             {return OVER;}
"("             {return LPAREN;} 
")"             {return RPAREN;}
"["             {return LBRACE;}
"]"             {return RBRACE;}
"{"             {return LCURLY;}
"}"             {return RCURLY;}
","             {return COMMA;}
";"             {return SEMI;}
{number}        {strncpy(numString,yytext,MAXTOKENLEN);return NUM;}
{identifier}    {strncpy(idString,yytext,MAXTOKENLEN); return ID;}
{newline}       {lineno++;}
{whitespace}    {/* skip whitespace */}
"/*"            { char c;
                  int inner_state = 0;
                  while(1)
                  { c = input();
                    if (c == EOF) break;
                    if (c == '\n') {
                      lineno++;
                      inner_state = 0;
                    }
                    else if (c == '*') {
                      inner_state = 1;
                    }
                    else if (inner_state == 1 && c == '/')
                     break;
                    else
                      inner_state = 0;
                  }
                }
.               {return ERROR;}

%%

TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
	if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    fprintf(listing,"\t%d: ",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
}

