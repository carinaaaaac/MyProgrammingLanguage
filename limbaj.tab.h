/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_LIMBAJ_TAB_H_INCLUDED
# define YY_YY_LIMBAJ_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 1 "limbaj.y"

  #include <iostream>
  #include <string>
  #include <vector>
  using namespace std;
  #include "symbol_table.hpp"
  #include "ASTnode.hpp"

  struct ExprInfo {
     ASTNode* node;
     string* type;
  };
  static void freeExpr(ExprInfo* e) {
     if(!e) return;
     delete e->node;
     delete e->type;
     delete e;
}

#line 69 "limbaj.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    BPROGRAM = 258,                /* BPROGRAM  */
    EPROGRAM = 259,                /* EPROGRAM  */
    BMAIN = 260,                   /* BMAIN  */
    EMAIN = 261,                   /* EMAIN  */
    ASSIGN = 262,                  /* ASSIGN  */
    BIF = 263,                     /* BIF  */
    THEN = 264,                    /* THEN  */
    ELSE = 265,                    /* ELSE  */
    EIF = 266,                     /* EIF  */
    BWHILE = 267,                  /* BWHILE  */
    DO = 268,                      /* DO  */
    EWHILE = 269,                  /* EWHILE  */
    BFOR = 270,                    /* BFOR  */
    FROM = 271,                    /* FROM  */
    TO = 272,                      /* TO  */
    EFOR = 273,                    /* EFOR  */
    TRUE = 274,                    /* TRUE  */
    FALSE = 275,                   /* FALSE  */
    AND = 276,                     /* AND  */
    OR = 277,                      /* OR  */
    NOT = 278,                     /* NOT  */
    EQ = 279,                      /* EQ  */
    NEQ = 280,                     /* NEQ  */
    LE = 281,                      /* LE  */
    GE = 282,                      /* GE  */
    LT = 283,                      /* LT  */
    GT = 284,                      /* GT  */
    PLUS = 285,                    /* PLUS  */
    MINUS = 286,                   /* MINUS  */
    MUL = 287,                     /* MUL  */
    DIV = 288,                     /* DIV  */
    BCLASS = 289,                  /* BCLASS  */
    ECLASS = 290,                  /* ECLASS  */
    PRIVATE = 291,                 /* PRIVATE  */
    PUBLIC = 292,                  /* PUBLIC  */
    PROTECTED = 293,               /* PROTECTED  */
    NEW = 294,                     /* NEW  */
    RETURN = 295,                  /* RETURN  */
    DOT = 296,                     /* DOT  */
    COMMA = 297,                   /* COMMA  */
    LEFTP = 298,                   /* LEFTP  */
    RIGHTP = 299,                  /* RIGHTP  */
    LEFTB = 300,                   /* LEFTB  */
    RIGHTB = 301,                  /* RIGHTB  */
    PRINT = 302,                   /* PRINT  */
    ID = 303,                      /* ID  */
    TYPE = 304,                    /* TYPE  */
    STRING_S = 305,                /* STRING_S  */
    INT_NR = 306,                  /* INT_NR  */
    FLOAT_NR = 307,                /* FLOAT_NR  */
    UMINUS = 308                   /* UMINUS  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 39 "limbaj.y"

     ExprInfo* Expr;
     string* Str;
     int Int;
     float Float;
     vector<Parameter>* Params;

#line 147 "limbaj.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_LIMBAJ_TAB_H_INCLUDED  */
