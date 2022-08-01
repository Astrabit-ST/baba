#ifndef OBJECT_HPP
#define OBJECT_HPP

#include "value.hpp"
#include <string>

enum ObjectType
{
    OBJ_STRING,
};

struct Object
{
    ObjectType type;
};

struct BabaString : Object
{
    BabaString(std::string str);

    std::string str;
};

#define OBJ_TYPE(value) VAL2OBJ(value)->type
#define IS_STRING(value) isObjType(value, OBJ_STRING)
#define VAL2STR(value) ((BabaString *)VAL2OBJ(value))->str
#define STR2VAL(value) OBJ2VAL(new BabaString(value))

inline bool
isObjType(BabaValue value, ObjectType type)
{
    return IS_OBJ(value) && OBJ_TYPE(value) == type;
}

void printObject(BabaValue value);

#endif
