#ifndef BABA_VALUE_H
#define BABA_VALUE_H

#include <variant>

struct Object;

enum ValueType
{
    VAL_BOOL,
    VAL_NIL,
    VAL_NUMBER,
    VAL_OBJECT,
};

typedef std::variant<bool, double, Object *> internal_value;

struct BabaValue
{
    BabaValue(internal_value value, ValueType type)
        : internal(value), type(type) {}

    template <typename T>
    T as()
    {
        return std::get<T>(internal);
    }
    bool equals(BabaValue other);

    ValueType type;
    internal_value internal;
};

void printValue(BabaValue value);

#define BOOL2VAL(value) BabaValue(value, VAL_BOOL)
#define VAL2BOOL(value) value.as<bool>()
#define IS_BOOL(value) value.type == VAL_BOOL

#define NUM2VAL(value) BabaValue(value, VAL_NUMBER)
#define VAL2NUM(value) value.as<double>()
#define IS_NUM(value) value.type == VAL_NUMBER

#define NIL2VAL BabaValue(false, VAL_NIL)
#define IS_NIL(value) value.type == VAL_NIL

#define OBJ2VAL(value) BabaValue(value, VAL_OBJECT)
#define IS_OBJ(value) value.type == VAL_OBJECT
#define VAL2OBJ(value) value.as<Object *>()

#endif
