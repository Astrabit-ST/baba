#include "compiler.hpp"
#include "lexer.hpp"
#include "parser.hpp"
#include <iostream>

bool Compiler::compile(const char *source, Chunk *chunk)
{
    RawNodePtr root_node = parse(source);

    if (success)
    {
        root_node->print();
        root_node->compile(chunk, this);

        delete root_node;
    }
    return success;
}

RawNodePtr Compiler::parse(const char *source)
{
    RawNodePtr root_node;

    //? Create and setup scanner
    yyscan_t scanner;
    yylex_init(&scanner);
    YY_BUFFER_STATE buf = yy_scan_string(source, scanner);

    //? Create parser
    yy::Parser parser(scanner, root_node);

    if (parser.parse())
    {
        success = false;
    }

    //? Clean up
    yy_delete_buffer(buf, scanner);
    yylex_destroy(scanner);

    return root_node;
}
