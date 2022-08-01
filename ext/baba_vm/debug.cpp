#include "debug.hpp"

using namespace std;

void disassembleChunk(Chunk *chunk, const char *name)
{
    cout << "== | disasm: " << name << " | ==" << endl;

    for (int offset = 0; offset < chunk->code.size();)
    {
        offset = disassembleInstruction(chunk, offset);
    }
    cout << "== | disasm: " << name << " | ==" << endl;
}

int simpleInstruction(const char *name, int offset)
{
    cout << name << endl;
    return offset + 1;
}

int constantInstruction(const char *name, Chunk *chunk, int offset)
{
    uint8_t constant = chunk->code[offset + 1];
    cout << name << " " << setfill('0') << setw(3) << +constant << " ";
    printValue(chunk->constants[constant]);
    cout << endl;
    return offset + 2;
}

int longConstantInstruction(const char *name, Chunk *chunk, int offset)
{
    uint16_t constant = chunk->code[offset + 1] |
                        (chunk->code[offset + 2] << 8);
    cout << name << " " << setfill('0') << setw(5) << constant << " ";
    printValue(chunk->constants[constant]);
    cout << endl;
    return offset + 3;
}

int disassembleInstruction(Chunk *chunk, int offset)
{
    cout << setfill('0') << setw(4) << offset << " ";

    if (offset > 0 && chunk->lines[offset] == chunk->lines[offset - 1])
    {
        cout << "   | ";
    }
    else
    {
        cout << setfill(' ') << setw(4) << chunk->lines[offset] << " ";
    }

    uint8_t instruction = chunk->code[offset];
    switch (instruction)
    {
    case OP_CONSTANT_LONG:
        return longConstantInstruction("OP_CONSTANT_LONG", chunk, offset);
    case OP_CONSTANT:
        return constantInstruction("OP_CONSTANT", chunk, offset);
    case OP_NIL:
        return simpleInstruction("OP_NIL", offset);
    case OP_TRUE:
        return simpleInstruction("OP_TRUE", offset);
    case OP_FALSE:
        return simpleInstruction("OP_FALSE", offset);
    case OP_EQUAL:
        return simpleInstruction("OP_EQUAL", offset);
    case OP_GREATER:
        return simpleInstruction("OP_GREATER", offset);
    case OP_LESS:
        return simpleInstruction("OP_LESS", offset);
    case OP_GREATER_EQUAL:
        return simpleInstruction("OP_GREATER_EQUAL", offset);
    case OP_LESS_EQUAL:
        return simpleInstruction("OP_LESS_EQUAL", offset);
    case OP_ADD:
        return simpleInstruction("OP_ADD", offset);
    case OP_SUBTRACT:
        return simpleInstruction("OP_SUBTRACT", offset);
    case OP_MULTIPLY:
        return simpleInstruction("OP_MULTIPLY", offset);
    case OP_DIVIDE:
        return simpleInstruction("OP_DIVIDE", offset);
    case OP_MODULO:
        return simpleInstruction("OP_MODULO", offset);
    case OP_NEGATE:
        return simpleInstruction("OP_NEGATE", offset);
    case OP_NOT:
        return simpleInstruction("OP_NOT", offset);
    case OP_RETURN:
        return simpleInstruction("OP_RETURN", offset);
    default:
        cout << "Unknown opcode " << instruction << endl;
        return offset + 1;
    }
}
