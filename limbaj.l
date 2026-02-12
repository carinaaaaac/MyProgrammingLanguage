%{
#include <stdio.h>
#include <stdlib.h>
#include "limbaj.tab.h"
#include <string>
%}


%option noyywrap

INT_NUMBER (0|[1-9][0-9]*)
FLOAT_NUMBER [0-9]+\.[0-9]+
STRING_LIT \"([^\\\"]|\\.)*\"

%%
"integer"|"float"|"text"|"bool"|"void" {yylval.Str = new std::string(yytext); return TYPE;}
"begin_program" {return BPROGRAM;}
"end_program" {return EPROGRAM;}
"begin_main" {return BMAIN;}
"end_main" {return EMAIN;}
"<-" {return ASSIGN;}
"if" {return BIF;}
"then" {return THEN;}
"else" {return ELSE;}
"endif" {return EIF;}
"while" {return BWHILE;}
"do" {return DO;}
"endwhile" {return EWHILE;}
"for" {return BFOR;}
"from" {return FROM;}
"to" {return TO;}
"endfor" {return EFOR;}
"true" {return TRUE;}
"false" {return FALSE;}
"and" {return AND;}  
"or" {return OR;}
"not" {return NOT;}
"==" {return EQ;}
"<>" {return NEQ;}
"<=" {return LE;}
">=" {return GE;}
"<" {return LT;}
">" {return GT;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MUL;}
"/" {return DIV;}
"begin_class" {return BCLASS;}
"end_class" {return ECLASS;}
"private" {return PRIVATE;}
"public" {return PUBLIC;}
"protected" {return PROTECTED;}
"new" {return NEW; }
"return" {return RETURN; }
"Print" {return PRINT;}
"." {return DOT;}
"," {return COMMA;}
"(" {return LEFTP;}
")" {return RIGHTP;}
"{" {return LEFTB;}
"}" {return RIGHTB;}

{FLOAT_NUMBER} {
    yylval.Float=(float)atof(yytext);
   return FLOAT_NR;
}
{INT_NUMBER} {
    yylval.Int=(int)atoi(yytext);
    return INT_NR;
}

{STRING_LIT} {
    yylval.Str=new std::string(yytext);
    return STRING_S;
}

[a-zA-Z][a-zA-Z0-9]* {yylval.Str = new std::string(yytext); return ID;}

[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
%%