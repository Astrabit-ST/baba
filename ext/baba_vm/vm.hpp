#ifndef VM_H
#define VM_H

#include "chunk.hpp"
#include <deque>
#include <unordered_map>

enum InterpretResult
{
    OK,
    COMPILE_ERROR,
    RUNTIME_ERROR
};

struct VM
{
    InterpretResult interpret(Chunk *chunk);
};

#endif
