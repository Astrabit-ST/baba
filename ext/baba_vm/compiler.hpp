#ifndef COMPILER_H
#define COMPILER_H
#include "chunk.hpp"
#include "ast.hpp"

struct Compiler
{
    bool compile(const char *source, Chunk *chunk);
    RawNodePtr parse(const char *source);

    bool success = true;
};

#endif
