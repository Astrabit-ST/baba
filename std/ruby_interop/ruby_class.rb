require_relative "class"

class Baba
  class RubyClass < BabaClass
    def initialize
    end

    def call(interpreter, arguments)
      klass = Kernel.const_get(arguments[0])
      instance = RubyObject.new(klass)

      return instance
    end

    def arity
      1
    end

    def to_s
      "RubyObject"
    end
  end
end
