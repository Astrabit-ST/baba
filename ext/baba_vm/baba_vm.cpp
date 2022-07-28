#include <ruby.h>
#include "common.hpp"
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
    for (int i = 0; i < 100000; i++)
        data->compiler.compile(source, &chunk);
    return Qfalse;
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
