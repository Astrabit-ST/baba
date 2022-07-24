%{
    #include "parser.hpp"
%}

DIGIT   [0-9]
ALPHA   [a-z_]\w*
BLANK   ([\ \t]+|\n|\r\n)
CONSTANT ([A-Z])
STRING  "([^"]|\\")*"

%option noyywrap
%option full
%option reentrant
/* %option bison-bridge */
%option outfile="lexer.cpp"
%option header="lexer.hpp"

%%

{BLANK} /* ignore blanks */
{DIGIT}+(.{DIGIT}+)?
{STRING}
"("
")"
","
"-"
"+"
"/"
"*"
";"
"{"
"}"
"."
"%"
"!="
"!"
"=="
">="
"<="
"="
">"
"<"
"thing"
"if"
"else"
"elsif"
"does"
"for"
"or"
"||"
"and"
"&&"
"return"
"super"
"self"
"var"
"while"
"false"
"true"
"break"
"switch"
"when"
"next"
"await"
"yield"
"include"
{CONSTANT}({ALPHA}|{DIGIT})*
{ALPHA}({ALPHA}|{DIGIT})*
.  /* unknown character */

%%
