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
      ancestor(distance).values[name] = value
    end

    def [](name)
      if @values.include?(name)
        return @values[name]
      end

      return @enclosing[name] unless @enclosing.nil?

      raise BabaRuntimeError.new("Undefined local variable or method '#{name}'.")
    end

    def []=(name, value)
      if @values.include?(name)
        @values[name] = value
        return
      end

      unless @enclosing.nil?
        @enclosing[name] = value
        return
      end

      raise BabaRuntimeError.new("Undefined local variable or method '#{name}'.")
    end
  end
end
