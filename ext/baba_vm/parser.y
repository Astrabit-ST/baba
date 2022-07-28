%{
    #include "lexer.hpp"
    #include <string>
    #include <vector>
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
%define parse.trace true
%param {yyscan_t scanner}
%parse-param {Node* root}

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

%type <Node> declaration thing_declaration does_declaration var_declaration statement
%type <Node> expression for_statement if_statement elsif_statement include_statement return_statement switch_statement
%type <Node> while_statement yield_statement block
%type <Node> assignment logic_or logic_and equality comparison term factor unary call primary
%type <Node> opt_expression for_initializer function
%type <std::string> sign_comparison sign_equality sign_factor sign_term sign_unary
%type <std::vector<Node>> arguments cases statements does_declarations declarations
%type <std::vector<std::string>> parameters

%%
program: declarations { *root = Program($1); } /* ... */
;

declaration: thing_declaration /* thing ... */
| does_declaration /* does ... */
| var_declaration /* var ... */
| statement /* ... */
;

declarations: { $$ = std::vector<Node>(); } /* nothing */
| declaration declarations { $2.insert($2.begin(), $1); $$ = $2; } /* ... ... */
;

thing_declaration: kTHING tCONSTANT tLEFT_BRACE does_declarations tRIGHT_BRACE { $$ = Thing($2, "", $4); } /* thing ... */
| kTHING tCONSTANT tLESS tCONSTANT tLEFT_BRACE does_declarations tRIGHT_BRACE { $$ = Thing($2, $4, $6); } /* thing ... < ... */
;

does_declaration: kDOES function { $$ = $2; } /* does ...(...) {} */
;

does_declarations: { $$ = std::vector<Node>(); } /* nothing */
| does_declaration does_declarations { $2.insert($2.begin(), $1); $$ = $2; } /* ... ... */
;

function: tIDENTIFIER tLEFT_PAREN parameters tRIGHT_PAREN block { $$ = Function($1, $3, $5); } /* ...(...) { ... } */

parameters: { $$ = std::vector<std::string>(); } /* nothing */
| tIDENTIFIER { $$ = std::vector<std::string>({$1}); } /* ... */
| tIDENTIFIER tCOMMA parameters { $3.insert($3.begin(), $1); $$ = $3; } /* ..., ..., ... */
;

var_declaration: kVAR tIDENTIFIER { $$ = Var($2, MissingNode()); } /* var ... */
| kVAR tIDENTIFIER tEQUAL expression { $$ = Var($2, $4); } /* var ... = ... */
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

statements: { $$ = std::vector<Node>(); } /* nothing */
| statement statements { $2.insert($2.begin(), $1); $$ = $2; } /* ... ... */
;

/* for ... , ... , ... */
for_statement: kFOR for_initializer tCOMMA opt_expression tCOMMA opt_expression statement {
    $$ = For($2, $4, $6, $7);
}
;

/* var ... | ... */
for_initializer: { $$ = MissingNode(); } /* nothing */
| var_declaration
| expression
;

if_statement: kIF expression statement { $$ = If($2, $3, MissingNode()); } /* if ... */
| kIF expression statement kELSE statement { $$ = If($2, $3, $5); } /* if ... else ... */
| kIF expression statement elsif_statement { $$ = If($2, $3, $4); } /* if ... elsif ... */
;

elsif_statement: kELSIF expression statement { $$ = If($2, $3, MissingNode()); } /*  elsif ... */
| kELSIF expression statement elsif_statement { $$ = If($2, $3, $4); } /* elsif ... elsif ... */
| kELSIF expression statement kELSE statement { $$ = If($2, $3, $5); } /* elsif ... else */
;

include_statement: kINCLUDE expression { $$ = Include($2); } /* include "..." */

return_statement: kRETURN opt_expression { $$ = Return($2); } /* return ... */
;

switch_statement: kSWITCH expression tLEFT_BRACE cases tRIGHT_BRACE { $$ = Switch($2, $4, MissingNode()); } /* switch ... { ... } */
| kSWITCH expression tLEFT_BRACE cases kELSE statement tRIGHT_BRACE { $$ = Switch($2, $4, $6); } /* switch ... { ... else ... } */
;

cases: kWHEN expression statement { $$ = std::vector<Node>({When($2, $3)}); } /* when ... */
| kWHEN expression statement cases { $4.insert($4.begin(), When($2, $3)); $$ = $4; } /* when ... when ... */
;

while_statement: kWHILE expression statement { $$ = While($2, $3); } /* while ... */
;

yield_statement: kYIELD opt_expression { $$ = YieldN($2); } /* yield ... */
;

block: tLEFT_BRACE statements tRIGHT_BRACE { $$ = Block($2); } /* { ... } */

expression: assignment /* ... */
;

opt_expression: { $$ = MissingNode(); } /* nothing */
| expression /* ... */
;

assignment: tIDENTIFIER tEQUAL assignment { $$ = Assign($1, $3); } /* ... = ... = ... */
| call tDOT tIDENTIFIER tEQUAL assignment { $$ = Set($1, $3, $5); } /* ...() = ... */
| logic_or /* ... */
;

logic_or: logic_and /* ... */
| logic_and kOR logic_or { $$ = Logical($1, "or", $3); } /* ... || ... || ... */
;

logic_and: equality /* ... */
| equality kAND logic_and { $$ = Logical($1, "and", $3); } /* ... && ... && ... */
;

equality: comparison /* ... */
| comparison sign_equality equality { $$ = Binary($1, $2, $3); } /* ... == ... == ... */
;

sign_equality: tEQUAL_EQUAL { $$ = "=="; } /* == */
| tNOT_EQUAL { $$ = "~="; } /* != */
;

comparison: term
| term sign_comparison comparison { $$ = Binary($1, $2, $3); } /* ... < ... < ... */
;

sign_comparison: tLESS { $$ = "<"; } /* < */
| tGREATER { $$ = ">"; } /* > */
| tLESS_EQUAL { $$ = "<="; } /* <= */
| tGREATER_EQUAL { $$ = ">="; } /* >= */
;

term: factor
| factor sign_term term { $$ = Binary($1, $2, $3); } /* ... + ... + ... */
;

sign_term: tPLUS { $$ = "+"; } /* + */
| tMINUS { $$ = "-"; } /* - */
;

factor: unary /* ... */
| unary sign_factor factor { $$ = Binary($1, $2, $3); } /* ... + ... - ... */
;

sign_factor: tSTAR { $$ = "*"; } /* * */
| tSLASH { $$ = "/"; } /* / */
| tMODULO { $$ = "%"; } /* % */
;

unary: call /* ... */
| sign_unary unary { $$ = Unary($1, $2); } /* -... */
;

sign_unary: tMINUS { $$ = "-"; } /* - */
| tNOT { $$ = "!"; } /* ! */
;

call: primary /* ... */
| call tLEFT_PAREN arguments tRIGHT_PAREN { $$ = Call($1, $3); } /* ... . ...(...) */
| call tDOT tIDENTIFIER { $$ = Get($1, $3); } /* ... (...) ... . ... */
;

arguments: { $$ = std::vector<Node>(); } /* nothing */
| expression { $$ = std::vector<Node>({$1}); } /* ... */
| expression tCOMMA arguments { $3.insert($3.begin(), $1); $$ = $3; } /* ..., ..., ... */
;

primary: tNUMBER { $$ = Literal<double>($1); }
| kTRUE { $$ = Literal<bool>(true); }
| kFALSE { $$ = Literal<bool>(false); }
| tSTRING { $$ = Literal<std::string>($1); }
| kBLANK { $$ = Literal<void*>(NULL); } /* Unsure of how to handle this */
| kBREAK { $$ = Break(); }
| kNEXT { $$ = Next(); }
| tIDENTIFIER { $$ = Variable($1); }
| tCONSTANT { $$ = Variable($1); }
| kSELF { $$ = Self(); }
| kSUPER tDOT tIDENTIFIER { $$ = Super($3); }
| tLEFT_PAREN expression tRIGHT_PAREN { $$ = Grouping($2); }
;
%%

auto yy::Parser::error(const std::string& msg) -> void {
    std::cout << "Error: " << msg << std::endl;
}
