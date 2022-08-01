#include <iostream>
#include <ast.hpp>

void print_sign(Sign sign)
{
    switch (sign)
    {
    case PLUS:
        std::cout << "+";
        break;
    case MINUS:
        std::cout << "-";
        break;
    case SLASH:
        std::cout << "/";
        break;
    case STAR:
        std::cout << "*";
        break;
    case MODULO:
        std::cout << "%";
        break;
    case EQUAL_EQUAL:
        std::cout << "==";
        break;
    case NOT_EQUAL:
        std::cout << "!=";
        break;
    case NOT:
        std::cout << "!";
    case AND:
        std::cout << "&&";
        break;
    case OR:
        std::cout << "||";
        break;
    case GREATER:
        std::cout << ">";
        break;
    case LESS:
        std::cout << "<";
        break;
    case GREATER_EQUAL:
        std::cout << ">=";
        break;
    case LESS_EQUAL:
        std::cout << "<=";
        break;
    }
}

void MissingNode::print()
{
    std::cout << "no node";
}

void Program::print()
{
    std::cout << "Program: " << std::endl;
    for (auto &declaration : declarations)
    {
        declaration->print();
        std::cout << std::endl;
    }
}

void Thing::print()
{
    std::cout << "thing " << name << " < " << superclass;
    for (auto &method : methods)
    {
        std::cout << std::endl;
        method->print();
    }
}

void Function::print()
{
    std::cout << "does " << name << "(";
    for (std::string param : params)
    {
        std::cout << param << ", ";
    }
    std::cout << ")";
    body->print();
    std::cout << std::endl;
}

void Var::print()
{
    std::cout << "var " << name << " = ";
    initializer->print();
}

void For::print()
{
    std::cout << "for ";
    initializer->print();
    std::cout << ", ";
    condition->print();
    std::cout << ", ";
    increment->print();
    body->print();
}

void If::print()
{
    std::cout << "if ";
    condition->print();
    then_branch->print();
    std::cout << "else ";
    else_branch->print();
}

void Include::print()
{
    std::cout << "include ";
    file->print();
}

void Return::print()
{
    std::cout << "return ";
    value->print();
}

void Switch::print()
{
    std::cout << "switch ";
    condition->print();
    std::cout << " { ";
    for (auto &case_ : cases)
    {
        std::cout << std::endl;
        case_->print();
    }
    std::cout << " else ";
    default_->print();
    std::cout << std::endl;
    std::cout << " } ";
}

void When::print()
{
    std::cout << "when ";
    condition->print();
    body->print();
}

void While::print()
{
    std::cout << "while";
    condition->print();
    body->print();
}

void YieldN::print()
{
    std::cout << "yield ";
    value->print();
}

void Block::print()
{
    std::cout << "{";
    for (auto &statement : statements)
    {
        std::cout << std::endl;
        statement->print();
    }
    std::cout << std::endl;
    std::cout << "}";
}

void Assign::print()
{
    std::cout << name << " = ";
    value->print();
}

void Set::print()
{
    object->print();
    std::cout << "." << name << " = ";
    value->print();
}

void Logical::print()
{
    left->print();
    std::cout << " ";
    print_sign(_operator);
    std::cout << " ";
    right->print();
}

void Binary::print()
{
    left->print();
    std::cout << " ";
    print_sign(_operator);
    std::cout << " ";
    right->print();
}

void Unary::print()
{
    print_sign(_operator);
    right->print();
}

void Call::print()
{
    callee->print();
    std::cout << "(";
    for (auto &arg : arguments)
    {
        arg->print();
        std::cout << ", ";
    }
    std::cout << ")";
}

void Get::print()
{
    object->print();
    std::cout << "." << name;
}

void Break::print()
{
    std::cout << "break";
}

void Next::print()
{
    std::cout << "next";
}

void Self::print()
{
    std::cout << "self";
}

void Variable::print()
{
    std::cout << name;
}

void Super::print()
{
    std::cout << "super." << member;
}

void Grouping::print()
{
    std::cout << "(";
    expression->print();
    std::cout << ")";
}

template <>
void Literal<void *>::print()
{
    std::cout << "blank";
}

template <>
void Literal<bool>::print()
{
    std::cout << (val ? "true" : "false");
}

template <>
void Literal<double>::print()
{
    std::cout << val;
}

template <>
void Literal<std::string>::print()
{
    std::cout << val;
}
