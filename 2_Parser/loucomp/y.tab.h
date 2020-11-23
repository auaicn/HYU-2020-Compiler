/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    ENDFILE = 258,
    IF = 259,
    ELSE = 260,
    WHILE = 261,
    INT = 262,
    VOID = 263,
    RETURN = 264,
    ID = 265,
    NUM = 266,
    PLUS = 267,
    MINUS = 268,
    TIMES = 269,
    OVER = 270,
    EQ = 271,
    NE = 272,
    LT = 273,
    LE = 274,
    GT = 275,
    GE = 276,
    LPAREN = 277,
    RPAREN = 278,
    LBRACE = 279,
    RBRACE = 280,
    LCURLY = 281,
    RCURLY = 282,
    ASSIGN = 283,
    SEMI = 284,
    COMMA = 285,
    ERROR = 286
  };
#endif
/* Tokens.  */
#define ENDFILE 258
#define IF 259
#define ELSE 260
#define WHILE 261
#define INT 262
#define VOID 263
#define RETURN 264
#define ID 265
#define NUM 266
#define PLUS 267
#define MINUS 268
#define TIMES 269
#define OVER 270
#define EQ 271
#define NE 272
#define LT 273
#define LE 274
#define GT 275
#define GE 276
#define LPAREN 277
#define RPAREN 278
#define LBRACE 279
#define RBRACE 280
#define LCURLY 281
#define RCURLY 282
#define ASSIGN 283
#define SEMI 284
#define COMMA 285
#define ERROR 286

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
