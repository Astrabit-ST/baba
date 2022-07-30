#ifndef AST_H
#define AST_H
#include "common.hpp"
#include <string>
#include <vector>
#include <iostream>

struct Compiler;

struct Node
{
    virtual ~Node()
    {
        // std::cout << "Node destructed" << std::endl;
    }
    virtual void compile(Chunk *chunk, Compiler *compiler)
    {
        std::cout << "Default node compile";
    }
    virtual void print()
    {
        std::cout << "Default node print";
    }
};

//? Unique pointer can be a pain in the ass to deal with because of moving,
//? so we don't actually pass them around in the parser- we only have them as members of the structs
//? at which point we don't need to care about moving them, since they have reached their owner

//? Raw node pointer type
typedef Node *RawNodePtr;
//? A vector of raw node pointers
typedef std::vector<RawNodePtr> RawNodeVector;

//? We use unique_ptr to avoid dealing with memory management
//? Otherwise, we'd have to manually manage memory for each node, and that's a pain in the ass
//? unique_ptr skirts around that by effectively doing that for us

//? A smart pointer to a Node
typedef std::unique_ptr<Node> NodePtr;
//? A vector of node spart pointers
typedef std::vector<NodePtr> NodeVector;

#define MoveNode(node) std::move(node)
#define MakeNode(type) new type
#define MakeMissing MakeNode(MissingNode())
#define RawVector2SmartVector(name)                      \
    for (auto it = name.begin(); it != name.end(); it++) \
    {                                                    \
        int index = std::distance(name.begin(), it);     \
        this->name[index].reset(*it);                    \
    }

//? Represents a node that doesn't exist (i.e a missing else statement)
struct MissingNode : Node
{
    void print();
};

//* Toplevel node
struct Program : Node
{
    Program(RawNodeVector declarations)
        : declarations(declarations.size())
    {
        RawVector2SmartVector(declarations);
    }
    void print();

    NodeVector declarations;
};

//* Statements

// * Thing
struct Thing : Node
{
    Thing(std::string name, std::string superclass, RawNodeVector methods)
        : name(name), superclass(superclass), methods(methods.size())
    {
        RawVector2SmartVector(methods);
    }
    void print();

    std::string name;
    std::string superclass;
    NodeVector methods;
};

// * Function
struct Function : Node
{
    Function(std::string name, std::vector<std::string> params, RawNodePtr body)
        : name(name), params(params), body(body) {}
    void print();

    std::string name;
    std::vector<std::string> params;
    NodePtr body;
};

// * Var
struct Var : Node
{
    Var(std::string name, RawNodePtr initializer)
        : name(name), initializer(initializer) {}
    void print();

    std::string name;
    NodePtr initializer;
};

// * For
struct For : Node
{
    For(RawNodePtr initializer, RawNodePtr condition, RawNodePtr increment, RawNodePtr body)
        : initializer(initializer), condition(condition),
          increment(increment), body(body) {}
    void print();

    NodePtr initializer;
    NodePtr condition;
    NodePtr increment;
    NodePtr body;
};

// * If
struct If : Node
{
    If(RawNodePtr condition, RawNodePtr then_branch, RawNodePtr else_branch)
        : condition(condition), then_branch(then_branch), else_branch(else_branch) {}
    void print();

    NodePtr condition;
    NodePtr then_branch;
    NodePtr else_branch;
};

// * Include
struct Include : Node
{
    Include(RawNodePtr file) : file(file) {}
    void print();

    NodePtr file;
};

// * Return
struct Return : Node
{
    Return(RawNodePtr value) : value(value) {}
    void print();

    NodePtr value;
};

// * Switch
struct Switch : Node
{
    Switch(RawNodePtr condition, RawNodeVector cases, RawNodePtr default_)
        : condition(condition), cases(cases.size()), default_(default_)
    {
        RawVector2SmartVector(cases);
    }
    void print();

    NodePtr condition;
    NodeVector cases;
    NodePtr default_;
};

// * When
struct When : Node
{
    When(RawNodePtr condition, RawNodePtr body)
        : condition(condition), body(body) {}
    void print();

    NodePtr condition;
    NodePtr body;
};

// * While
struct While : Node
{
    While(RawNodePtr condition, RawNodePtr body)
        : condition(condition), body(body) {}
    void print();

    NodePtr condition;
    NodePtr body;
};

// * Yield
struct YieldN : Node //! Yield is a fucking macro on windows
{
    YieldN(RawNodePtr value) : value(value) {}
    void print();

    NodePtr value;
};

// * Block
struct Block : public Node
{
    Block(RawNodeVector statements) : statements(statements.size())
    {
        RawVector2SmartVector(statements);
    }
    void print();

    NodeVector statements;
};

//* Expressions

// * Assignment
struct Assign : Node
{
    Assign(std::string name, RawNodePtr value)
        : name(name), value(value) {}
    void print();

    std::string name;
    NodePtr value;
};

struct Set : Node
{
    Set(RawNodePtr object, std::string name, RawNodePtr value)
        : object(object), name(name), value(value) {}
    void print();

    NodePtr object;
    std::string name;
    NodePtr value;
};

// * Logical
struct Logical : Node
{
    Logical(RawNodePtr left, std::string _operator, RawNodePtr right)
        : left(left), _operator(_operator), right(right) {}
    void print();

    NodePtr left;
    std::string _operator;
    NodePtr right;
};

// * Binary
struct Binary : Node
{
    Binary(RawNodePtr left, std::string _operator, RawNodePtr right)
        : left(left), _operator(_operator), right(right) {}
    void print();

    NodePtr left;
    std::string _operator;
    NodePtr right;
};

// * Unary
struct Unary : Node
{
    Unary(std::string _operator, RawNodePtr right)
        : _operator(_operator), right(right) {}
    void print();

    std::string _operator;
    NodePtr right;
};

// * Call
struct Call : Node
{
    Call(RawNodePtr callee, RawNodeVector arguments)
        : callee(callee), arguments(arguments.size())
    {
        RawVector2SmartVector(arguments);
    }
    void print();

    NodePtr callee;
    NodeVector arguments;
};

struct Get : Node
{
    Get(RawNodePtr object, std::string name)
        : object(object), name(name) {}
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
    Grouping(RawNodePtr expression) : expression(expression) {}
    void print();

    NodePtr expression;
};

// * Literal gets special treatment because templates :)

template <typename T>
struct Literal : Node
{
    void compile(Chunk *chunk, Compiler *compiler){};
    void print()
    {
        std::cout << val;
    }

    Literal(T t) : val(t) {}

    T val;
};
#endif
