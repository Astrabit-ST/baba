#include <ruby.h>
#include "chunk.hpp"
#include "vm.hpp"
#include "compiler.hpp"

struct Baba
{
    VM vm;
    Compiler compiler;
};

const rb_data_type_t baba_type = {
    .wrap_struct_name = "baba",
    .function = {
        .dmark = NULL,
        .dfree = [](void *data)
        { delete (Baba *)data; },
        .dsize = [](const void *data)
        { return sizeof(Baba); }},
    .data = NULL,
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

VALUE rb_baba_run(VALUE self, VALUE string)
{
    char *source = StringValueCStr(string);

    Baba *data;

    TypedData_Get_Struct(self, Baba, &baba_type, data);

    Chunk chunk;
    InterpretResult result = COMPILE_ERROR;
    if (data->compiler.compile(source, &chunk))
    {
        result = data->vm.interpret(&chunk);
    }
    return INT2NUM(result);
}

VALUE rb_baba_alloc(VALUE self)
{
    Baba *data = new Baba();

    return TypedData_Wrap_Struct(self, &baba_type, data);
}

extern "C" void Init_baba_vm(void)
{
    VALUE klass = rb_define_class("Baba", rb_cObject);
    rb_define_alloc_func(klass, rb_baba_alloc);
    rb_define_method(klass, "run", rb_baba_run, 1);
}
