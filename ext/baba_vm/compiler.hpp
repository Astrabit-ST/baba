#ifndef COMPILER_H
#define COMPILER_H
#include "common.hpp"
#include "lexer.hpp"
#include "parser.hpp"

struct Compiler
{
    Compiler();
    ~Compiler();
    bool compile(const char *source, Chunk *chunk);

    yyscan_t scanner;
    yy::Parser *parser;
};

#endif
