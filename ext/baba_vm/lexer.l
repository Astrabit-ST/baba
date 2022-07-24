%{
#include "lexer.hpp"

Token makeToken(TokenType type)
{
    Token token;
    token.type = type;
    return token;
}
%}

DIGIT   [0-9]
ALPHA   [a-z_]\w*
BLANK   ([\ \t]+|\n|\r\n)
CONSTANT ([A-Z])\w*
STRING  "([^"]|\\")*"

%option c++
/* %option yyclass="Lexer" */
%option noyywrap
%option full
/* %option reentrant */
/* %option bison-bridge */

%%

{BLANK} /* ignore blanks */
{DIGIT}+(.{DIGIT}+)? return tNUMBER;
{STRING} return tSTRING;
"(" return tLPAREN;
")" return tRPAREN;
"," return tCOMMA;
"-" return tMINUS;
"+" return tPLUS;
"/" return tSLASH;
"*" return tSTAR;
";" return tSEMICOLON;
"{" return tLBRACE;
"}" return tRBRACE;
"." return tDOT;
"%" return tMODULO;
"!=" return tNEQUAL;
"!" return tNOT;
"==" return tDEQUAL;
">=" return tGEQUAL;
"<=" return tLEQUAL;
"=" return tEQUAL;
">" return tGREATER;
"<" return tLESS;
"thing" return tTHING;
"if" return tIF;
"else" return tELSE;
"elsif" return tELSIF;
"does" return tDOES;
"for" return tFOR;
"or" return tOR;
"||" return tOR;
"and" return tAND;
"&&" return tAND;
"return" return tRETURN;
"super" return tSUPER;
"self" return tSELF;
"var" return tVAR;
"while" return tWHILE;
"false" return tFALSE;
"true" return tTRUE;
"break" return tBREAK;
"switch" return tSWITCH;
"when" return tWHEN;
"next" return tNEXT;
"await" return tAWAIT;
"yield" return tYIELD;
"include" return tINCLUDE;
{CONSTANT} return tCONSTANT;
{ALPHA}({ALPHA}|{DIGIT})* return tIDENTIFIER;
. return tERROR; /* unknown character */

%%
