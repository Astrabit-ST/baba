#include "vm.hpp"
#include "debug.hpp"
#include <cmath>

InterpretResult VM::interpret(const char *source)
{
    return OK;
}

#define READ_BYTE *(instruction_pointer++)
#define DEBUG_TRACE
#define BINARY_OPERATOR(operator) \
    BabaValue b = pop_stack();    \
    BabaValue a = pop_stack();    \
    push_stack(a operator b);     \
    break;

InterpretResult VM::run()
{
    while (true)
    {
#ifdef DEBUG_TRACE
        for (BabaValue v : stack)
        {
            std::cout << "[ ";
            printValue(v);
            std::cout << " ]" << std::endl;
        }
        disassembleInstruction(chunk, instruction_pointer - chunk->code.data());
#endif
        uint8_t instruction = READ_BYTE; //? Move pointer allong to read bytes
        switch (instruction)
        {
        case OP_CONSTANT:
        {
            BabaValue constant = chunk->constants[READ_BYTE];
            push_stack(constant);
            break;
        }
        case OP_CONSTANT_LONG:
        {
            uint16_t index = READ_BYTE |
                             (READ_BYTE << 8);
            BabaValue constant = chunk->constants[index];
            push_stack(constant);
            break;
        }
        case OP_ADD:
        {
            BINARY_OPERATOR(+);
        }
        case OP_SUBTRACT:
        {
            BINARY_OPERATOR(-);
        }
        case OP_MULTIPLY:
        {
            BINARY_OPERATOR(*);
        }
        case OP_DIVIDE:
        {
            BINARY_OPERATOR(/);
        }
        case OP_MODULO:
        {
            BabaValue b = pop_stack();
            BabaValue a = pop_stack();
            push_stack(fmod(a, b));
        }
        case OP_NEGATE:
            push_stack(-pop_stack());
            break;
        case OP_RETURN:
            printValue(pop_stack());
            return OK;
        }
    }
}

void VM::push_stack(BabaValue value)
{
    stack.push_back(value);
}

BabaValue VM::pop_stack()
{
    BabaValue top = stack.back();
    stack.pop_back();
    return top;
}
