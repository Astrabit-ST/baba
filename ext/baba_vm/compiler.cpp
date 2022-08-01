#include "compiler.hpp"
#include "lexer.hpp"
#include "parser.hpp"
#include "object.hpp"
#include <iostream>

bool Compiler::compile(const char *source, Chunk *chunk)
{
    RawNodePtr root_node = parse(source);

    if (success)
    {
        // root_node->print();
        root_node->compile(chunk, this);

        delete root_node;
    }
    chunk->write(OP_RETURN, 0);
    return success;
}

RawNodePtr Compiler::parse(const char *source)
{
    RawNodePtr root_node;

    //? Create and setup scanner
    yyscan_t scanner;
    yylex_init(&scanner);
    YY_BUFFER_STATE buf = yy_scan_string(source, scanner);

    //? Create parser
    yy::Parser parser(scanner, root_node);

    if (parser.parse())
    {
        success = false;
    }

    //? Clean up
    yy_delete_buffer(buf, scanner);
    yylex_destroy(scanner);

    return root_node;
}

// TODO: Add line number support

void Program::compile(Chunk *chunk, Compiler *compiler)
{
    for (auto &declaration : declarations)
    {
        declaration->compile(chunk, compiler);
    }
}

void Binary::compile(Chunk *chunk, Compiler *compiler)
{
    left->compile(chunk, compiler);
    right->compile(chunk, compiler);
    switch (_operator)
    {
    case PLUS:
        chunk->write(OP_ADD, 0);
        break;
    case MINUS:
        chunk->write(OP_SUBTRACT, 0);
        break;
    case STAR:
        chunk->write(OP_MULTIPLY, 0);
        break;
    case SLASH:
        chunk->write(OP_DIVIDE, 0);
        break;
    case MODULO:
        chunk->write(OP_MODULO, 0);
        break;
    case LESS:
        chunk->write(OP_LESS, 0);
        break;
    case GREATER:
        chunk->write(OP_GREATER, 0);
        break;
    case LESS_EQUAL:
        chunk->write(OP_LESS_EQUAL, 0);
        break;
    case GREATER_EQUAL:
        chunk->write(OP_GREATER_EQUAL, 0);
        break;
    case EQUAL_EQUAL:
        chunk->write(OP_EQUAL, 0);
        break;
    }
}

void Unary::compile(Chunk *chunk, Compiler *compiler)
{
    right->compile(chunk, compiler);
    switch (_operator)
    {
    case NOT:
        chunk->write(OP_NOT, 0);
        break;
    case MINUS:
        chunk->write(OP_NEGATE, 0);
        break;
    }
}

template <>
void Literal<double>::compile(Chunk *chunk, Compiler *compiler)
{
    chunk->writeConstant(NUM2VAL(val), 0);
}

template <>
void Literal<std::string>::compile(Chunk *chunk, Compiler *compiler)
{
    chunk->writeConstant(STR2VAL(val), 0);
}

template <>
void Literal<bool>::compile(Chunk *chunk, Compiler *compiler)
{
    chunk->write(val ? OP_TRUE : OP_FALSE, 0);
}

// FIXME: void* is hack to represent NIL
template <>
void Literal<void *>::compile(Chunk *chunk, Compiler *compiler)
{
    chunk->write(OP_NIL, 0);
}
