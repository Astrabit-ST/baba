#ifndef OBJECT_H
#define OBJECT_H

#include <string>

typedef Value BasicObject *;

struct BasicObject
{
    void define_method(std::string name, Value (*fn)(...), int argc);
};

struct Object : public BasicObject
{
};

struct Class : public Object
{
};

#endif
