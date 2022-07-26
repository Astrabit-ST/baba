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
{STRING} { yylval->emplace<std::string>(std::string(yytext)); return Parser::token::tSTRING; }
"#".*\n /* ignore comments */
"(" { return Parser::token::tLEFT_PAREN; }
")" { return Parser::token::tRIGHT_PAREN; }
"," { return Parser::token::tCOMMA; }
"-" { return Parser::token::tMINUS; }
"+" { return Parser::token::tPLUS; }
"/" { return Parser::token::tSLASH; }
"*" { return Parser::token::tSTAR; }
";" { return Parser::token::tSEMICOLON; }
"{" { return Parser::token::tLEFT_BRACE; }
"}" { return Parser::token::tRIGHT_BRACE; }
"." { return Parser::token::tDOT; }
"%" { return Parser::token::tMODULO; }
"!=" { return Parser::token::tNOT_EQUAL; }
"!" { return Parser::token::tNOT; }
"==" { return Parser::token::tEQUAL_EQUAL; }
">=" { return Parser::token::tGREATER_EQUAL; }
"<=" { return Parser::token::tLESS_EQUAL; }
"=" { return Parser::token::tEQUAL; }
">" { return Parser::token::tGREATER; }
"<" { return Parser::token::tLESS; }
"thing" { return Parser::token::kTHING; }
"if" { return Parser::token::kIF; }
"else" { return Parser::token::kELSE; }
"elsif" { return Parser::token::kELSIF; }
"does" { return Parser::token::kDOES; }
"for" { return Parser::token::kFOR; }
"or" { return Parser::token::kOR; }
"||" { return Parser::token::kOR; }
"and" { return Parser::token::kAND; }
"&&" { return Parser::token::kAND; }
"return" { return Parser::token::kRETURN; }
"super" { return Parser::token::kSUPER; }
"self" { return Parser::token::kSELF; }
"var" { return Parser::token::kVAR; }
"while" { return Parser::token::kWHILE; }
"false" { return Parser::token::kFALSE; }
"true" { return Parser::token::kTRUE; }
"break" { return Parser::token::kBREAK; }
"switch" { return Parser::token::kSWITCH; }
"when" { return Parser::token::kWHEN; }
"next" { return Parser::token::kNEXT; }
"await" { return Parser::token::kAWAIT; }
"yield" { return Parser::token::kYIELD; }
"include" { return Parser::token::kINCLUDE; }
{DIGIT}+(.{DIGIT}+)? { yylval->emplace<double>(std::stod(yytext)); return Parser::token::tNUMBER; }
{CONSTANT}({ALPHA}|{DIGIT})* { yylval->emplace<std::string>(std::string(yytext)); return Parser::token::tCONSTANT; }
{ALPHA}({ALPHA}|{DIGIT})* { yylval->emplace<std::string>(std::string(yytext)); return Parser::token::tIDENTIFIER; }
.  /* unknown character */

%%
