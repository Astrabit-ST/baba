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
tSEMICOLON ";" /* unused */
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
tERROR "error" /* scanner error */

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
kAWAIT "await" /* unused */
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
program: declarations /* ... */
;

declaration: thing_delclaration /* thing ... */
| does_declaration /* does ... */
| var_declaration /* var ... */
| statement /* ... */
;

declarations: /* nothing */
| declaration declarations
;

thing_delclaration: kTHING tCONSTANT tLEFT_BRACE does_declarations tRIGHT_BRACE {std::cout << "thing " << $2; } /* thing ... */
| kTHING tCONSTANT tLESS tCONSTANT tLEFT_BRACE does_declarations tRIGHT_BRACE { std::cout << "thing " << $2 << " < " << $4; } /* thing ... < ... */
;

does_declaration: kDOES function { std::cout << "does "; } /* does ...(...) {} */
;

does_declarations: /* nothing */
| does_declaration does_declarations
;

function: tIDENTIFIER tLEFT_PAREN parameters tRIGHT_PAREN block { std::cout << $1; } /* ...(...) { ... } */

parameters: /* nothing */
| tIDENTIFIER { std::cout << $1; } /* ... */
| tIDENTIFIER tCOMMA parameters { std::cout << $1; } /* ..., ..., ... */
;

var_declaration: kVAR tIDENTIFIER { std::cout << "var " << $2; } /* var ... */
| kVAR tIDENTIFIER tEQUAL expression { std::cout << "var " << $2 << " = "; } /* var ... = ... */
;

statement: expression /* ... */
| for_statement /* for ... */
| if_statement /* if ... */
| include_statement /* include ... */
| return_statement /* return ... */
| switch_statement /* switch ... */
| while_statement /* while ... */
| yield_statement /* yield ... */
| block /* { ... } */
;

/* for ... , ... , ... */
for_statement: kFOR for_initializer tCOMMA opt_expression tCOMMA opt_expression statement { std::cout << "for "; }
;

/* var ... | ... */
for_initializer: /* nothing */
| var_declaration
| expression
;

if_statement: kIF expression statement { std::cout << "if "; } /* if ... */
| kIF expression statement kELSE statement { std::cout << "if " << "else"; } /* if ... else ... */
| kIF expression statement elsif_statement { std::cout << "if "; } /* if ... elsif ... */
;

elsif_statement: kELSIF expression statement { std::cout << "elsif "; } /*  elsif ... */
| kELSIF expression statement elsif_statement { std::cout << "elsif "; } /* elsif ... elsif ... */
| kELSIF expression statement kELSE statement { std::cout << "elsif " << "else "; } /* elsif ... else */
;

include_statement: kINCLUDE expression { std::cout << "include "; } /* include "..." */

return_statement: kRETURN opt_expression { std::cout << "return "; } /* return ... */
;

switch_statement: kSWITCH expression tLEFT_BRACE cases tRIGHT_BRACE { std::cout << "switch "; } /* switch ... { ... } */
| kSWITCH expression tLEFT_BRACE cases kELSE statement tRIGHT_BRACE { std::cout << "switch " << "else "; } /* switch ... { ... else ... } */
;

cases: kWHEN expression statement { std::cout << "when "; } /* when ... */
| kWHEN expression statement cases { std::cout << "when "; } /* when ... when ... */
;

while_statement: kWHILE expression statement { std::cout << "while "; } /* while ... */
;

yield_statement: kYIELD opt_expression { std::cout << "yield "; } /* yield ... */
;

block: tLEFT_BRACE declarations tRIGHT_BRACE { std::cout << "{ } "; } /* { ... } */

expression: assignment /* ... */
;

opt_expression: /* nothing */
| expression
;

assignment: tIDENTIFIER tEQUAL assignment { std::cout << $1 << " = "; } /* ... = ... = ... */
| call tDOT tIDENTIFIER tEQUAL assignment { std::cout << "." << $3 << " = "; } /* ...() = ... */
| logic_or /* ... */
;

logic_or: logic_and /* ... */
| logic_and kOR logic_or { std::cout << " or "; }/* ... || ... || ... */
;

logic_and: equality /* ... */
| equality kAND logic_and { std::cout << " and "; } /* ... && ... && ... */
;

equality: comparison /* ... */
| comparison sign_equality equality /* ... == ... == ... */
;

sign_equality: tEQUAL_EQUAL { std::cout << " == "; } /* == */
| tNOT_EQUAL { std::cout << " != "; } /* != */
;

comparison: term
| term sign_comparison comparison /* ... < ... < ... */
;

sign_comparison: tLESS { std::cout << " < "; } /* < */
| tGREATER { std::cout << " > "; } /* > */
| tLESS_EQUAL { std::cout << " <= "; } /* <= */
| tGREATER_EQUAL { std::cout << " >= "; } /* >= */
;

term: factor
| factor sign_term term /* ... + ... + ... */
;

sign_term: tPLUS { std::cout << " + "; } /* + */
| tMINUS /* - */
;

factor: unary /* ... */
| unary sign_factor factor /* ... + ... - ... */
;

sign_factor: tSTAR { std::cout << " * "; } /* * */
| tSLASH { std::cout << " / "; } /* / */
| tMODULO { std::cout << " % "; } /* % */
;

unary: sign_unary unary /* -... */
| call /* ... */
;

sign_unary: tMINUS { std::cout << " -"; } /* - */
| tNOT { std::cout << " !"; } /* ! */
;

call: primary /* ... */
| call tLEFT_PAREN arguments tRIGHT_PAREN { std::cout << "( )"; } /* ... . ...(...) */
| call tDOT tIDENTIFIER { std::cout << "." << $3; } /* ... (...) ... . ... */
;

arguments: /* nothing */
| expression /* ... */
| expression tCOMMA arguments /* ..., ..., ... */
;

primary: tNUMBER { std::cout << $1; }
| kTRUE { std::cout << "true"; }
| kFALSE { std::cout << "false"; }
| kBLANK { std::cout << "blank"; }
| kBREAK { std::cout << "break"; }
| kNEXT { std::cout << "next"; }
| tIDENTIFIER { std::cout << $1; }
| tCONSTANT { std::cout << $1; }
| kSELF { std::cout << "self"; }
| kSUPER tDOT tIDENTIFIER { std::cout << "super." << $3; }
| tLEFT_PAREN expression tRIGHT_PAREN { std::cout << "( )"; }
;
%%

auto yy::Parser::error(const std::string& msg) -> void {
    std::cout << "Error: " << msg << std::endl;
}
