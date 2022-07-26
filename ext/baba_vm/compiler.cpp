#include "compiler.hpp"

Compiler::Compiler()
{
    yylex_init(&scanner);
    parser = new yy::Parser(scanner);
}

Compiler::~Compiler()
{
    yylex_destroy(scanner);
    delete parser;
}

bool Compiler::compile(const char *source, Chunk *chunk)
{
    YY_BUFFER_STATE buf = yy_scan_string(source, scanner);
    parser->parse();
    yy_delete_buffer(buf, scanner);
    return false;
}
