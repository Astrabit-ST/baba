#include "vm.hpp"
#include "debug.hpp"
#include <cmath>
#include <cstdarg>

// #define DEBUG_TRACE

InterpretResult VM::interpret(Chunk *chunk)
{
#ifdef DEBUG_TRACE
    disassembleChunk(chunk, "TEST");
#endif

    this->chunk = chunk;
    instruction_pointer = chunk->code.data();
    return run();
}

#define READ_BYTE *(instruction_pointer++)
#define BINARY_OPERATOR(operator, convert)         \
    if (!IS_NUM(peek(0)) || !IS_NUM(peek(1)))      \
    {                                              \
        runtimeError("Operands must be numbers."); \
        return RUNTIME_ERROR;                      \
    }                                              \
    double b = VAL2NUM(pop_stack());               \
    double a = VAL2NUM(pop_stack());               \
    push_stack(convert(a operator b));             \
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
        case OP_NIL:
        {
            push_stack(NIL2VAL);
            break;
        }
        case OP_TRUE:
        {
            push_stack(BOOL2VAL(true));
            break;
        }
        case OP_FALSE:
        {
            push_stack(BOOL2VAL(false));
            break;
        }
        case OP_EQUAL:
        {
            BabaValue b = pop_stack();
            BabaValue a = pop_stack();
            push_stack(BOOL2VAL(a.equals(b)));
            break;
        }
        case OP_NOT_EQUAL:
        {
            BabaValue b = pop_stack();
            BabaValue a = pop_stack();
            push_stack(BOOL2VAL(!a.equals(b)));
            break;
        }
        case OP_GREATER:
        {
            BINARY_OPERATOR(>, BOOL2VAL);
        }
        case OP_LESS:
        {
            BINARY_OPERATOR(<, BOOL2VAL);
        }
        case OP_GREATER_EQUAL:
        {
            BINARY_OPERATOR(>=, BOOL2VAL);
        }
        case OP_LESS_EQUAL:
        {
            BINARY_OPERATOR(<=, BOOL2VAL);
        }
        case OP_ADD:
        {
            if (IS_STRING(peek(0)) && IS_STRING(peek(1)))
            {
                std::string b = VAL2STR(pop_stack());
                std::string a = VAL2STR(pop_stack());
                push_stack(STR2VAL(a + b));
            }
            else if (IS_NUM(peek(0)) && IS_NUM(peek(1)))
            {
                double b = VAL2NUM(pop_stack());
                double a = VAL2NUM(pop_stack());
                push_stack(NUM2VAL(a + b));
            }
            else
            {
                runtimeError("Operands must be two numbers or two strings.");
                return RUNTIME_ERROR;
            }
            break;
        }
        case OP_SUBTRACT:
        {
            BINARY_OPERATOR(-, NUM2VAL);
        }
        case OP_MULTIPLY:
        {
            BINARY_OPERATOR(*, NUM2VAL);
        }
        case OP_DIVIDE:
        {
            BINARY_OPERATOR(/, NUM2VAL);
        }
        case OP_MODULO:
        {
            if (!IS_NUM(peek(0)) || !IS_NUM(peek(1)))
            {
                runtimeError("Operands must be numbers.");
                return RUNTIME_ERROR;
            }
            double b = VAL2NUM(pop_stack());
            double a = VAL2NUM(pop_stack());
            push_stack(NUM2VAL(
                fmod(a, b)));
        }
        case OP_NEGATE:
        {
            if (!IS_NUM(peek(0)))
            {
                runtimeError("Operand must be a number");
                return RUNTIME_ERROR;
            }
            push_stack(NUM2VAL(-VAL2NUM(pop_stack())));
            break;
        }
        case OP_NOT:
        {
            push_stack(BOOL2VAL(isFalsey(pop_stack())));
            break;
        }
        case OP_RETURN:
        {
            printValue(pop_stack());
            return OK;
        }
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

BabaValue VM::peek(int distance)
{
    return stack[stack.size() - 1 - distance];
}

bool VM::isFalsey(BabaValue value)
{
    return IS_NIL(value) || (IS_BOOL(value) && !VAL2BOOL(value));
}

void VM::runtimeError(const char *format, ...)
{
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fputs("\n", stderr);

    size_t instruction = instruction_pointer - chunk->code.data() - 1;
    int line = chunk->lines[instruction];
    fprintf(stderr, "[line %d] in script\n", line);
    stack.clear();
}
