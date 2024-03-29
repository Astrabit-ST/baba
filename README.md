# baba

baba is an embeddable scripting language which runs inside of ruby, and can seamlessly interop with ruby functions and objects.
It is closest to C# in syntax, although does not feature semicolons at all.
There are no primitives in baba- only objects.

# Embedding in ruby

Baba will take control of your ruby program when executing, and will yield execution when baba runs into a `yield`, optionally yielding a value which can be retrieved from `Baba.yielded_value`.
You can check if baba is yielded with `Baba.yielded?`. Resuming execution is done by `Baba.continue` or `Baba.resume`. (alias)
It's also possible to optionally specify an execution limit with `Baba.execution_limit` to automatically yield.

Multiple baba interpreters can be created and run at once too!

Baba may optionally compile down to a bytecode that can then be run at runtime.

# Ruby API

From baba, it is possible to interop with ruby classes via the `RubyObject` class. You can pass in a classname to "get" the class, then call `new` on it to actually instantiate the class.
This functionality is to enable you to call class functions like `SomeClass.class_method` and to also call class instance methods at will.
Calling Ruby functions is fine as long as you don't pass in a complex Baba object not represented in Ruby.

It is also possible to create baba classes _from_ Ruby if you desire. This is used by baba for its "core" types and baba's `Object` class.
baba provides a semi-packed Ruby API, akin to Ruby's C API. Allmost all baba objects are represented by `Baba::Instance`, sort of like Ruby's `VALUE` and various functions can be used to manipulate or them.
You can also create classes and methods in a "ruby extension" and load them in baba.

# Todo

- [ ] Basic standard library (IO, Time, etc)
- [ ] Better include statement
- [ ] Include ruby files
- [ ] Default Object superclass
- [ ] Lists
- [ ] Everything is an object:tm:
- [ ] Splat args
- [ ] Default args
- [ ] rb_call
- [ ] Better error handling
- [ ] Operator overloading
- [ ] +=, \*= etc...
- [ ] Metaclasses
- [ ] Move to ANTLR
