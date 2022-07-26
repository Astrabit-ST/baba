#ifndef COMPILER_H
#define COMPILER_H
#include "common.hpp"
#include "lexer.hpp"
#include "parser.hpp"

struct Compiler
{
    bool compile(const char *source, Chunk *chunk);
};

#endif
