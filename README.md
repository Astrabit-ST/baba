# Baba

Baba is an embeddable scripting language, designed to be simple to embed inside of a ruby program.
It's main goal, for now, is making an alternative to the RPG Maker XP interpreter that can run alongside it.
Ruby (especially in the case of writing events or dialogue) is overkill, and baba is a simple stopgap between it.
Baba, should, in theory, be able to be applied to anything else in a similar context, though.

Baba has a basic ruby interface (you can create ruby objects at will) upon which the standard library is based upon. 
You can also call ruby methods with `rb_eval`, or `rb_func` (unimplemented), but I would not recommend using it to modify the state of the interpreter.
Baba provides little to no handholding without the standard library, even lacking a `print` function, or arrays. 
You do not have to implement such things yourself, though. 