#ifndef AST_H
#define AST_H
#include "common.hpp"
#include <string>
#include <vector>
#include <iostream>

struct Node
{
    virtual void compile(Chunk *chunk) {}
    virtual void print() {}
};

//? Represents a node that doesn't exist (i.e a missing else statement)
struct MissingNode : Node
{
};

//* Toplevel node
struct Program : Node
{
    Program(std::vector<Node> declarations) : declarations(declarations) {}
    void print();

    std::vector<Node> declarations;
};

//* Statements

// * Thing
struct Thing : Node
{
    Thing(std::string name, std::string superclass, std::vector<Node> methods)
        : name(name), superclass(superclass), methods(methods) {}
    void print();

    std::string name;
    std::string superclass;
    std::vector<Node> methods;
};

// * Function
struct Function : Node
{
    Function(std::string name, std::vector<std::string> params, Node body)
        : name(name), params(params), body(body) {}
    void print();

    std::string name;
    std::vector<std::string> params;
    Node body;
};

// * Var
struct Var : Node
{
    Var(std::string name, Node initializer)
        : name(name), initializer(initializer) {}
    void print();

    std::string name;
    Node initializer;
};

// * For
struct For : Node
{
    For(Node initializer, Node condition, Node increment, Node body)
        : initializer(initializer), condition(condition), increment(increment), body(body) {}
    void print();

    Node initializer;
    Node condition;
    Node increment;
    Node body;
};

// * If
struct If : Node
{
    If(Node condition, Node then_branch, Node else_branch)
        : condition(condition), then_branch(then_branch), else_branch(else_branch) {}
    void print();

    Node condition;
    Node then_branch;
    Node else_branch;
};

// * Include
struct Include : Node
{
    Include(Node file) : file(file) {}
    void print();

    Node file;
};

// * Return
struct Return : Node
{
    Return(Node value) : value(value) {}
    void print();

    Node value;
};

// * Switch
struct Switch : Node
{
    Switch(Node condition, std::vector<Node> cases, Node default_)
        : condition(condition), cases(cases), default_(default_) {}
    void print();

    Node condition;
    std::vector<Node> cases;
    Node default_;
};

// * When
struct When : Node
{
    When(Node condition, Node body) : condition(condition), body(body) {}
    void print();

    Node condition;
    Node body;
};

// * While
struct While : Node
{
    While(Node condition, Node body)
        : condition(condition), body(body) {}
    void print();

    Node condition;
    Node body;
};

// * Yield
struct YieldN : Node //! Yield is a fucking macro on windows
{
    YieldN(Node value) : value(value) {}
    void print();

    Node value;
};

// * Block
struct Block : public Node
{
    Block(std::vector<Node> statements) : statements(statements) {}
    void print();

    std::vector<Node> statements;
};

//* Expressions

// * Assignment
struct Assign : Node
{
    Assign(std::string name, Node value)
        : name(name), value(value) {}
    void print();

    std::string name;
    Node value;
};

struct Set : Node
{
    Set(Node object, std::string name, Node value)
        : object(object), name(name), value(value) {}
    void print();

    Node object;
    std::string name;
    Node value;
};

// * Logical
struct Logical : Node
{
    Logical(Node left, std::string _operator, Node right)
        : left(left), _operator(_operator), right(right) {}
    void print();

    Node left;
    std::string _operator;
    Node right;
};

// * Binary
struct Binary : Node
{
    Binary(Node left, std::string _operator, Node right)
        : left(left), _operator(_operator), right(right) {}
    void print();

    Node left;
    std::string _operator;
    Node right;
};

// * Unary
struct Unary : Node
{
    Unary(std::string _operator, Node right)
        : _operator(_operator), right(right) {}
    void print();

    std::string _operator;
    Node right;
};

// * Call
struct Call : Node
{
    Call(Node callee, std::vector<Node> arguments)
        : callee(callee), arguments(arguments) {}
    void print();

    Node callee;
    std::vector<Node> arguments;
};

struct Get : Node
{
    Get(Node object, std::string name)
        : object(object), name(name) {}
    void print();

    Node object;
    std::string name;
};

// * Primary
struct Break : Node
{
    void print();
};

struct Next : Node
{
    void print();
};

struct Self : Node
{
    void print();
};

struct Variable : Node
{
    Variable(std::string name) : name(name) {}
    void print();

    std::string name;
};

struct Super : Node
{
    Super(std::string member) : member(member) {}
    void print();

    std::string member;
};

struct Grouping : Node
{
    Grouping(Node expression) : expression(expression) {}
    void print();

    Node expression;
};

// * Literal gets special treatment because templates :)

template <typename T>
struct Literal : Node
{
    void compile(Chunk *chunk){};
    void print()
    {
        std::cout << val;
    }

    Literal(T t) : val(t) {}

    T val;
};
#endif
