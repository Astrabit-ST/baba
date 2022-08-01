#include "object.hpp"
#include "value.hpp"
#include <iostream>

BabaString::BabaString(std::string str)
    : str(str)
{
    type = OBJ_STRING;
}

void printObject(BabaValue value)
{
    switch (OBJ_TYPE(value))
    {
    case OBJ_STRING:
    {
        std::cout << VAL2STR(value);
        break;
    }
    }
}
