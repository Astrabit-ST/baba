#include "common.hpp"

void Chunk::write(uint8_t byte, int line)
{
    code.push_back(byte);
    lines.push_back(line);
}

int Chunk::addConstant(BabaValue value)
{
    constants.push_back(value);
    return constants.size() - 1;
}

void Chunk::writeConstant(BabaValue value, int line)
{
    int index = addConstant(value);
    //? If we have more than 256 constants, use the long opcode instead
    if (index < 256)
    {
        write(OP_CONSTANT, line);
        write(index, line);
    }
    else
    {
        write(OP_CONSTANT_LONG, line);
        //? Max of 65 thousand or so but nobody will reach that
        write(index & 0xff, line);
        write((index >> 8) & 0xff, line);
    }
}

void printValue(BabaValue value)
{
    std::cout << "'" << value << "'";
}
