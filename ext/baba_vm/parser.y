%{
    #include "lexer.hpp"
    #include <string>
    #include <iostream>
    #include <cmath>
%}

%language "c++"
%defines "parser.hpp"
%output "parser.cpp"
%require "3.5"
%define api.parser.class {Parser}
%define api.value.type variant
%param {yyscan_t scanner}

%code provides
{
    #define YY_DECL \
        int yylex(yy::Parser::semantic_type *yylval, yyscan_t yyscanner)
    YY_DECL;
}

%token
tLEFT_PAREN "("
tRIGHT_PAREN ")"
tCOMMA ","
tMINUS "-"
tPLUS "+"
tSLASH "/"
tSTAR "*"
tSEMICOLON ";"
tLEFT_BRACE "{"
tRIGHT_BRACE "}"
tDOT "."
tMODULO "%"
tNOT "!"
tNOT_EQUAL "!="
tEQUAL "="
tEQUAL_EQUAL "=="
tGREATER ">"
tLESS "<"
tGREATER_EQUAL ">="
tLESS_EQUAL "<="
tERROR "error"

%token
kTHING "thing"
kIF "if"
kELSE "else"
kELSIF "elsif"
kDOES "does"
kFOR "for"
kOR "or"
kAND "and"
kRETURN "return"
kSUPER "super"
kSELF "self"
kVAR "var"
kWHILE "while"
kBREAK "break"
kINCLUDE "include"
kSWITCH "switch"
kWHEN "when"
kNEXT "next"
kAWAIT "await"
kYIELD "yield"

%token <std::string> tIDENTIFIER
%token <std::string> tCONSTANT
%token <std::string> tSTRING
%token <double> tNUMBER

%token <bool> kFALSE "false"
%token <bool> kTRUE "true"
%token kBLANK "blank"

%left tPLUS tMINUS
%left tSTAR tSLASH tMODULO

%%
program: declarations
;

declarations: /* nothing */
| declaration declarations
;

declaration: expression
;

expression: binary
;

binary: primary
| binary tPLUS binary
| binary tMINUS binary
| binary tSLASH binary
| binary tSTAR binary
| binary tMODULO binary
;

primary: tNUMBER
| kTRUE
| kFALSE
| kBLANK
| tIDENTIFIER
| tCONSTANT
| kSELF
| kSUPER tDOT tIDENTIFIER
| tLEFT_PAREN expression tRIGHT_PAREN
;
%%

auto yy::Parser::error(const std::string& msg) -> void {
    std::cout << "Error: " << msg << std::endl;
}
