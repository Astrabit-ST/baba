#include "object.hpp"
#include "value.hpp"
#include <iostream>

void printValue(BabaValue value)
{
    switch (value.type)
    {
    case VAL_BOOL:
    {
        std::cout << (VAL2BOOL(value) ? "true" : "false");
        break;
    }
    case VAL_NIL:
    {
        std::cout << "blank";
        break;
    }
    case VAL_NUMBER:
    {
        std::cout << VAL2NUM(value);
        break;
    }
    case VAL_OBJECT:
    {
        printObject(value);
        break;
    }
    }
}

bool BabaValue::equals(BabaValue other)
{
    if (type != other.type)
        return false;

    switch (type)
    {
    case VAL_BOOL:
        return as<bool>() == other.as<bool>();
    case VAL_NIL:
        return true;
    case VAL_NUMBER:
        return as<double>() == other.as<double>();
    case VAL_OBJECT:
        std::string a = ((BabaString *)as<Object *>())->str;
        std::string b = VAL2STR(other);
        return a == b;
    }
    return false;
}
