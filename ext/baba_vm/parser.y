%{
    #include "lexer.hpp"
%}

%language "c++"
%defines "parser.hpp"
%output "parser.cpp"
%require "3.2"

%union {
    int i;
}

%%
lines   : %empty
;
%%

auto yy::parser::error(const std::string& msg) -> void {
    std::cout << "Error: " << msg << std::endl;
}
