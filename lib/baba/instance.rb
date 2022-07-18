require_relative "runtime_error"

class Baba
  class Instance
    def initialize(klass)
      @klass = klass
      @fields = {}
    end

    def [](name)
      if @fields.include?(name)
        return @fields[name]
      end

      method = @klass.find_method(name)
      return method.bind(self) unless method.nil?

      raise BabaRuntimeError.new("Undefined property #{name}.")
    end

    def []=(name, value)
      @fields[name] = value
    end

    def to_s
      base_string = "<#{@klass.name} instance:"
      @fields.each do |field, value|
        base_string += " #{field} => #{value}"
      end
      base_string += ">"
    end

    def inspect
      to_s
    end
  end
end
