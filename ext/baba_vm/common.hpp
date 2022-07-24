#ifndef COMMON_H
#define COMMON_H

#include <ruby.h>
#include <vector>
#include <cstdint>
#include <iostream>
#include <iomanip>

typedef double BabaValue;

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

//? Print a value to cout
void printValue(BabaValue value);

enum OpCode
{
    //? Followed by 1 byte to denote constant index
    OP_CONSTANT,
    //? Followed by 2 bytes to denote constant index
    OP_CONSTANT_LONG,
    //? + operator
    OP_ADD,
    //? - operator
    OP_SUBTRACT,
    //? * operator
    OP_MULTIPLY,
    //? / uperator
    OP_DIVIDE,
    //? % operator
    OP_MODULO,
    //? Negate unary operator
    OP_NEGATE,
    //? Signal end of bytecode
    OP_RETURN,
};

#endif
