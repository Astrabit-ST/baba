require_relative "runtime_error"

class Baba
  class Environment
    attr_reader :enclosing, :values

    def initialize(enclosing = nil)
      @enclosing = enclosing
      @values = {}
    end

    def define(name, value)
      @values[name] = value
    end

    def ancestor(distance)
      environment = self
      1.upto(distance) do
        environment = environment.enclosing
      end

      environment
    end

    def get_at(distance, name)
      ancestor(distance).values[name]
    end

    def assign_at(distance, name, value)
      ancestor(distance).values[name.lexeme] = value
    end

    def [](name)
      if @values.include?(name.lexeme)
        return @values[name.lexeme]
      end

      return @enclosing[name] unless @enclosing.nil?

      raise BabaRuntimeError.new(name, "Undefined local variable or method '#{name.lexeme}'.")
    end

    def []=(name, value)
      if @values.include?(name.lexeme)
        @values[name.lexeme] = value
        return
      end

      unless @enclosing.nil?
        @enclosing[name] = value
        return
      end

      raise BabaRuntimeError.new(name, "Undefined local variable or method '#{name.lexme}'.")
    end
  end
end
