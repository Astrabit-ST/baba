%{
    #include "parser.hpp"
    using namespace yy;
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
{DIGIT}+(.{DIGIT}+)? { yylval->emplace<double>(std::stod(yytext)); return Parser::token::tNUMBER; }
{STRING} { yylval->emplace<std::string>(std::string(yytext)); return Parser::token::tSTRING; }
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
{CONSTANT}({ALPHA}|{DIGIT})* { yylval->emplace<std::string>(std::string(yytext)); return Parser::token::tCONSTANT; }
{ALPHA}({ALPHA}|{DIGIT})* { yylval->emplace<std::string>(std::string(yytext)); return Parser::token::tIDENTIFIER; }
.  /* unknown character */

%%
