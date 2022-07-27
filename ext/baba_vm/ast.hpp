#ifndef AST_H
#define AST_H
#include "common.hpp"
#include <vector>
#include <iostream>

struct Node
{
    virtual void compile(Chunk *chunk) {}
    virtual void print()
    {
        for (Node node : children)
        {
            node.print();
        }
    }

    std::vector<Node> children;
    int line;
};

template <typename T>
struct Literal : Node
{
    void compile(Chunk *chunk);
    void print();

    Literal(T t) : val(t) {}
    T val;
};

// Seperate files for template implementations
#include "compiler.tcc"    // void compile(Chunk* chunk) implementations
#include "ast_printer.tcc" // void print() implementations
#endif
