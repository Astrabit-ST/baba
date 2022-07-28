#ifndef AST_H
#define AST_H
#include "common.hpp"
#include <string>
#include <vector>
#include <iostream>
#include <memory>

struct Node
{
    virtual void compile(Chunk *chunk) {}
    virtual void print() {}
};

//? We use unique_ptr to avoid dealing with memory management
//? Otherwise, we'd have to manually manage memory for each node, and that's a pain in the ass
//? unique_ptr skirts around that by effectively doing that for us
typedef std::unique_ptr<Node> NodePtr;
typedef std::vector<NodePtr> NodeVector;

#define MoveNode(node) std::move(node)
#define MakeNode(type) NodePtr(new type)
#define MakeMissing MakeNode(MissingNode())

//? Represents a node that doesn't exist (i.e a missing else statement)
struct MissingNode : Node
{
};

//* Toplevel node
struct Program : Node
{
    Program(NodeVector declarations) : declarations(MoveNode(declarations)) {}
    void print();

    NodeVector declarations;
};

//* Statements

// * Thing
struct Thing : Node
{
    Thing(std::string name, std::string superclass, NodeVector methods)
        : name(name), superclass(superclass), methods(MoveNode(methods)) {}
    void print();

    std::string name;
    std::string superclass;
    NodeVector methods;
};

// * Function
struct Function : Node
{
    Function(std::string name, std::vector<std::string> params, NodePtr body)
        : name(name), params(MoveNode(params)), body(MoveNode(body)) {}
    void print();

    std::string name;
    std::vector<std::string> params;
    NodePtr body;
};

// * Var
struct Var : Node
{
    Var(std::string name, NodePtr initializer)
        : name(name), initializer(MoveNode(initializer)) {}
    void print();

    std::string name;
    NodePtr initializer;
};

// * For
struct For : Node
{
    For(NodePtr initializer, NodePtr condition, NodePtr increment, NodePtr body)
        : initializer(MoveNode(initializer)), condition(MoveNode(condition)),
          increment(MoveNode(increment)), body(MoveNode(body)) {}
    void print();

    NodePtr initializer;
    NodePtr condition;
    NodePtr increment;
    NodePtr body;
};

// * If
struct If : Node
{
    If(NodePtr condition, NodePtr then_branch, NodePtr else_branch)
        : condition(MoveNode(condition)), then_branch(MoveNode(then_branch)), else_branch(MoveNode(else_branch)) {}
    void print();

    NodePtr condition;
    NodePtr then_branch;
    NodePtr else_branch;
};

// * Include
struct Include : Node
{
    Include(NodePtr file) : file(MoveNode(file)) {}
    void print();

    NodePtr file;
};

// * Return
struct Return : Node
{
    Return(NodePtr value) : value(MoveNode(value)) {}
    void print();

    NodePtr value;
};

// * Switch
struct Switch : Node
{
    Switch(NodePtr condition, NodeVector cases, NodePtr default_)
        : condition(MoveNode(condition)), cases(MoveNode(cases)), default_(MoveNode(default_)) {}
    void print();

    NodePtr condition;
    NodeVector cases;
    NodePtr default_;
};

// * When
struct When : Node
{
    When(NodePtr condition, NodePtr body) : condition(MoveNode(condition)), body(MoveNode(body)) {}
    void print();

    NodePtr condition;
    NodePtr body;
};

// * While
struct While : Node
{
    While(NodePtr condition, NodePtr body)
        : condition(MoveNode(condition)), body(MoveNode(body)) {}
    void print();

    NodePtr condition;
    NodePtr body;
};

// * Yield
struct YieldN : Node //! Yield is a fucking macro on windows
{
    YieldN(NodePtr value) : value(MoveNode(value)) {}
    void print();

    NodePtr value;
};

// * Block
struct Block : public Node
{
    Block(NodeVector statements) : statements(MoveNode(statements)) {}
    void print();

    NodeVector statements;
};

//* Expressions

// * Assignment
struct Assign : Node
{
    Assign(std::string name, NodePtr value)
        : name(name), value(MoveNode(value)) {}
    void print();

    std::string name;
    NodePtr value;
};

struct Set : Node
{
    Set(NodePtr object, std::string name, NodePtr value)
        : object(MoveNode(object)), name(name), value(MoveNode(value)) {}
    void print();

    NodePtr object;
    std::string name;
    NodePtr value;
};

// * Logical
struct Logical : Node
{
    Logical(NodePtr left, std::string _operator, NodePtr right)
        : left(MoveNode(left)), _operator(_operator), right(MoveNode(right)) {}
    void print();

    NodePtr left;
    std::string _operator;
    NodePtr right;
};

// * Binary
struct Binary : Node
{
    Binary(NodePtr left, std::string _operator, NodePtr right)
        : left(MoveNode(left)), _operator(_operator), right(MoveNode(right)) {}
    void print();

    NodePtr left;
    std::string _operator;
    NodePtr right;
};

// * Unary
struct Unary : Node
{
    Unary(std::string _operator, NodePtr right)
        : _operator(_operator), right(MoveNode(right)) {}
    void print();

    std::string _operator;
    NodePtr right;
};

// * Call
struct Call : Node
{
    Call(NodePtr callee, NodeVector arguments)
        : callee(MoveNode(callee)), arguments(MoveNode(arguments)) {}
    void print();

    NodePtr callee;
    NodeVector arguments;
};

struct Get : Node
{
    Get(NodePtr object, std::string name)
        : object(MoveNode(object)), name(name) {}
    void print();

    NodePtr object;
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
    Grouping(NodePtr expression) : expression(MoveNode(expression)) {}
    void print();

    NodePtr expression;
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
