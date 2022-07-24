#include <ruby.h>
#include "common.hpp"
#include "vm.hpp"
#include "debug.hpp"

VALUE rb_baba_run(VALUE self, VALUE string)
{
    char *str = StringValueCStr(string);
    VM vm;
    return INT2NUM(vm.interpret(str));
}

extern "C" void Init_baba_vm(void)
{
    VALUE klass = rb_define_class("Baba", rb_cObject);
    rb_define_method(klass, "run", rb_baba_run, 1);
}
