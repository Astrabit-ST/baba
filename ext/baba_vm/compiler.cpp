#include "compiler.hpp"
#include <iostream>

bool Compiler::compile(const char *source, Chunk *chunk)
{
    NodePtr root_node;

    yyscan_t scanner;
    yylex_init(&scanner);
    yy::Parser parser(scanner, root_node);
    // parser.set_debug_level(1);

    yy_scan_string(source, scanner);

    if (parser.parse())
        return false; //! Failed to parse

    root_node->print();
    return true;
}
