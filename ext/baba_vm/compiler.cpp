#include "compiler.hpp"
#include "lexer.hpp"
#include <FlexLexer.h>
#include <iostream>
#include <sstream>

void compile(const char *source)
{
    std::stringstream ss(source);
    yyFlexLexer lexer = yyFlexLexer(ss, std::cout);
    while (true)
    {
        int i = lexer.yylex();
        std::cout << lexer.yywrap() << "|" << i << std::endl;
        if (i == 0)
            break;
    }
}
