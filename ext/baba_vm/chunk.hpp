#ifndef COMMON_H
#define COMMON_H

#include <vector>
#include <cstdint>
#include <iostream>
#include <iomanip>
#include "value.hpp"

const short VERSION = 260; //* 2.6.0

struct Chunk
{
public:
    void write(uint8_t byte, int line);
    //? Add a constant to the constant array (constants are literals)
    int addConstant(BabaValue value);
    //? Write a constant to the bytecode (adds a constant and also changes the instruction based on amount of constants)
    void writeConstant(BabaValue value, int line);

    //? Store byte code in a vector
    std::vector<uint8_t> code;
    //! FIXME: memory inefficient
    std::vector<int> lines;
    std::vector<BabaValue> constants;
};

enum OpCode
{
    //? Followed by 1 byte to denote constant index
    OP_CONSTANT,
    //? Followed by 2 bytes to denote constant index
    OP_CONSTANT_LONG,
    //? Constant literals (nil, false, etc)
    OP_NIL,
    OP_TRUE,
    OP_FALSE,
    //? Comparison operators
    OP_EQUAL,
    OP_NOT_EQUAL,
    OP_GREATER,
    OP_LESS,
    OP_GREATER_EQUAL,
    OP_LESS_EQUAL,
    //? Arithmetic operators
    OP_ADD,
    OP_SUBTRACT,
    OP_MULTIPLY,
    OP_DIVIDE,
    OP_MODULO,
    //? Not unary operator
    OP_NOT,
    //? Negate unary operator
    OP_NEGATE,
    //? Signal end of bytecode
    OP_RETURN,
};

#endif
