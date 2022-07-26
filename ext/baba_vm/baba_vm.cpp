#include <ruby.h>
#include "common.hpp"
#include "vm.hpp"
#include "compiler.hpp"

VALUE rb_baba_run(VALUE self, VALUE string)
{
    char *source = StringValueCStr(string);
    Chunk chunk;

    Compiler compiler;
    if (!compiler.compile(source, &chunk))
        return INT2NUM(COMPILE_ERROR);

    VM vm;
    return INT2NUM(vm.interpret(&chunk));
}

extern "C" void Init_baba_vm(void)
{
    VALUE klass = rb_define_class("Baba", rb_cObject);
    rb_define_method(klass, "run", rb_baba_run, 1);
}
