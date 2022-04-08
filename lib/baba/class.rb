require_relative "callable"
require_relative "instance"

class Baba
  class BabaClass < Callable
    attr_reader :name, :methods, :superclass

    def initialize(name, superclass, methods)
      @name = name
      @methods = methods
      @superclass = superclass
    end

    def call(interpreter, arguments)
      instance = Instance.new(self)
      initializer = find_method("init")
      unless initializer.nil?
        initializer.bind(instance).call(interpreter, arguments)
      end

      return instance
    end

    def arity
      initializer = find_method("init")
      unless initializer.nil?
        initializer.arity
      else
        0
      end
    end

    def find_method(method)
      if @methods.include?(method)
        return @methods[method]
      end

      unless @superclass.nil?
        return superclass.find_method(method)
      end
    end

    def to_s
      "<#{@name}>"
    end

    def inspect
      "<#{@name} < #{superclass.inspect} : #{@methods.inspect}>"
    end
  end
end
