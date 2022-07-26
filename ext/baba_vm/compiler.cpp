#include "compiler.hpp"

bool Compiler::compile(const char *source, Chunk *chunk)
{
    yyscan_t scanner;
    yylex_init(&scanner);
    yy_scan_string(source, scanner);
    yy::Parser parser(scanner);
    parser.parse();
    yylex_destroy(scanner);
}
