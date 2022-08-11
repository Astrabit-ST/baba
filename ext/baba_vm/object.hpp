#ifndef OBJECT_H
#define OBJECT_H

#include <string>

struct BasicObject;
typedef BasicObject *Value;

/* A basic, barebones object which all objects inherit from */
struct BasicObject 
{
  /* Define a method on this class */
  void define_method(std::string name, Value (*fn)(...), int argc);
};

/* To be defined in object.cpp */
extern Value Object;
extern Value Class;

/* Class definition functions */
Value define_class(std::string name, Value super);
Value define_class_under(std::string name, Value super, Value under);

#endif
