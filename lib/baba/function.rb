require_relative "callable"
require_relative "environment"
require_relative "interpreter"

require_relative "environment"

class Baba
  class Function < Callable
    def initialize(declaration, closure)
      @declaration = declaration
      @closure = closure
    end

    def bind(instance)
      environment = Environment.new(@closure)
      environment.define("self", instance)
      Function.new(@declaration, environment)
    end

    def call(interpreter, arguments)
      environment = Environment.new(@closure)
      @declaration.params.each_with_index do |p, i|
        environment.define(p, arguments[i])
      end

      begin
        interpreter.execute_block(@declaration.body.statements, environment)
      rescue Return => value
        return value.value
      end
      nil
    end

    def arity
      @declaration.params.size
    end

    def to_s
      "<fn: #{@declaration.name}>"
    end
  end
end
