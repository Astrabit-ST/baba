%{
    #include "lexer.hpp"
    #include <string>
    #include <iostream>
    #include <cmath>
%}

%code requires {
    #include "ast.hpp"
}

%code provides
{
    #define YY_DECL \
        int yylex(yy::Parser::semantic_type *yylval, yyscan_t yyscanner)
    YY_DECL;
}

%language "c++"
%defines "parser.hpp"
%output "parser.cpp"
%require "3.5"
%define api.parser.class {Parser}
%define api.value.type variant
%param {yyscan_t scanner}

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

%type <Node> declaration thing_delclaration does_declaration var_declaration statement
%type <Node> expression for_statement if_statement include_statement return_statement switch_statement
%type <Node> while_statement yield_statement block
%type <Node> assignment logic_or logic_and equality comparison term factor unary call primary

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

thing_delclaration: kTHING tCONSTANT tLEFT_BRACE does_declarations tRIGHT_BRACE /* thing ... */
| kTHING tCONSTANT tLESS tCONSTANT tLEFT_BRACE does_declarations tRIGHT_BRACE /* thing ... < ... */
;

does_declaration: kDOES function /* does ...(...) {} */
;

does_declarations: /* nothing */
| does_declaration does_declarations
;

function: tIDENTIFIER tLEFT_PAREN parameters tRIGHT_PAREN block /* ...(...) { ... } */

parameters: /* nothing */
| tIDENTIFIER /* ... */
| tIDENTIFIER tCOMMA parameters /* ..., ..., ... */
;

var_declaration: kVAR tIDENTIFIER /* var ... */
| kVAR tIDENTIFIER tEQUAL expression /* var ... = ... */
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
for_statement: kFOR for_initializer tCOMMA opt_expression tCOMMA opt_expression statement
;

/* var ... | ... */
for_initializer: /* nothing */
| var_declaration
| expression
;

if_statement: kIF expression statement /* if ... */
| kIF expression statement kELSE statement /* if ... else ... */
| kIF expression statement elsif_statement /* if ... elsif ... */
;

elsif_statement: kELSIF expression statement /*  elsif ... */
| kELSIF expression statement elsif_statement /* elsif ... elsif ... */
| kELSIF expression statement kELSE statement /* elsif ... else */
;

include_statement: kINCLUDE expression /* include "..." */

return_statement: kRETURN opt_expression /* return ... */
;

switch_statement: kSWITCH expression tLEFT_BRACE cases tRIGHT_BRACE /* switch ... { ... } */
| kSWITCH expression tLEFT_BRACE cases kELSE statement tRIGHT_BRACE /* switch ... { ... else ... } */
;

cases: kWHEN expression statement /* when ... */
| kWHEN expression statement cases /* when ... when ... */
;

while_statement: kWHILE expression statement /* while ... */
;

yield_statement: kYIELD opt_expression /* yield ... */
;

block: tLEFT_BRACE declarations tRIGHT_BRACE /* { ... } */

expression: assignment /* ... */
;

opt_expression: /* nothing */
| expression
;

assignment: tIDENTIFIER tEQUAL assignment /* ... = ... = ... */
| call tDOT tIDENTIFIER tEQUAL assignment /* ...() = ... */
| logic_or /* ... */
;

logic_or: logic_and /* ... */
| logic_and kOR logic_or { std::cout << " or "; }/* ... || ... || ... */
;

logic_and: equality /* ... */
| equality kAND logic_and /* ... && ... && ... */
;

equality: comparison /* ... */
| comparison sign_equality equality /* ... == ... == ... */
;

sign_equality: tEQUAL_EQUAL /* == */
| tNOT_EQUAL /* != */
;

comparison: term
| term sign_comparison comparison /* ... < ... < ... */
;

sign_comparison: tLESS /* < */
| tGREATER /* > */
| tLESS_EQUAL /* <= */
| tGREATER_EQUAL /* >= */
;

term: factor
| factor sign_term term /* ... + ... + ... */
;

sign_term: tPLUS /* + */
| tMINUS /* - */
;

factor: unary /* ... */
| unary sign_factor factor /* ... + ... - ... */
;

sign_factor: tSTAR /* * */
| tSLASH /* / */
| tMODULO /* % */
;

unary: sign_unary unary /* -... */
| call /* ... */
;

sign_unary: tMINUS /* - */
| tNOT /* ! */
;

call: primary /* ... */
| call tLEFT_PAREN arguments tRIGHT_PAREN /* ... . ...(...) */
| call tDOT tIDENTIFIER /* ... (...) ... . ... */
;

arguments: /* nothing */
| expression /* ... */
| expression tCOMMA arguments /* ..., ..., ... */
;

primary: tNUMBER { $$ = Literal<double>($1); }
| kTRUE { $$ = Literal<bool>(true); }
| kFALSE { $$ = Literal<bool>(false); }
| tSTRING { $$ = Literal<std::string>($1); }
| kBLANK
| kBREAK
| kNEXT
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
