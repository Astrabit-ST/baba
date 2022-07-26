#ifndef VM_H
#define VM_H

#include "common.hpp"
#include <deque>

enum InterpretResult
{
    OK,
    COMPILE_ERROR,
    RUNTIME_ERROR
};

struct VM
{
public:
    InterpretResult interpret(Chunk *chunk);
    InterpretResult run();
    void push_stack(BabaValue value);
    BabaValue pop_stack();

    Chunk *chunk;
    //! Pointer to the current byte we are executing
    uint8_t *instruction_pointer;
    std::deque<BabaValue> stack;
};

#endif
