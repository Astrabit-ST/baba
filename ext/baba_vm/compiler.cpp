#include "compiler.hpp"

bool Compiler::compile(const char *source, Chunk *chunk)
{
    Node root_node;

    yyscan_t scanner;
    yylex_init(&scanner);
    yy::Parser parser(scanner, &root_node);

    yy_scan_string(source, scanner);

    parser.parse();
    root_node.print();
}
