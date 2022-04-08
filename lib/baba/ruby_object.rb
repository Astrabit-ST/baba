require_relative "instance"
require_relative "function"
require_relative "class"
require_relative "runtime_error"

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

  class RubyObject < Instance
    def initialize(klass)
      super(klass)
      @methods = klass.methods.map { |m| m.to_s }
      @object = nil # By default our object is nil
    end

    def [](name)
      klass = if @object.nil?
          @klass
        else
          @object
        end

      if name.lexeme == "new"
        method = @klass.method(name.lexeme)
        return RubyFunction.new(method, proc do |ret|
                 @object = ret
                 @methods = ret.methods.map { |m| m.to_s }
               end)
      end

      if name.lexeme == "array_get" # Tis is not the best idea but it works
        if @methods.include?("[]")
          method = klass.method("[]")
          return RubyFunction.new(method)
        end
      end

      if name.lexeme == "array_set"
        if @methods.include?("[]=")
          method = klass.method("[]=")
          return RubyFunction.new(method)
        end
      end

      if @methods.include?(name.lexeme)
        method = klass.method(name.lexeme)
        return RubyFunction.new(method)
      end

      raise BabaRuntimeError.new(name, "Undefined method #{name.lexeme} for #{@klass}.")
    end

    def []=(name, value)
      klass = if @object.nil?
          @klass
        else
          @object
        end

      if @methods.include?[name.lexme + "="]
        method = klass.method(name.lexeme + "=")
        method.call(value)
      else
        raise BabaRuntimeError.new(name, "Undefined method #{name.lexme}= for #{@klass}.")
      end
    end

    def to_s
      "<Ruby #{@klass}: #{@object.inspect}>"
    end
  end

  class RubyFunction < Function
    def initialize(method, callback = nil)
      @method = method
      @callback = callback
    end

    def call(interpreter, arguments)
      ret = @method.call(*arguments)
      if @callback
        @callback.call(ret)
      end
      return ret
    end

    def arity
      @method.arity
    end

    def to_s
      "<ruby fn: #{@method}>"
    end
  end
end
