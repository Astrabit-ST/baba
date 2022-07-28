#include "compiler.hpp"
#include <iostream>

bool Compiler::compile(const char *source, Chunk *chunk)
{
    NodePtr root_node;

    yyscan_t scanner;
    yylex_init(&scanner);
    yy::Parser parser(scanner, root_node);
    // parser.set_debug_level(1);

    YY_BUFFER_STATE buf = yy_scan_string(source, scanner);

    if (!parser.parse())
    {
        root_node->print();
    }

    yy_delete_buffer(buf, scanner);
    yylex_destroy(scanner);
    root_node.reset(NULL);
    return false;
}
