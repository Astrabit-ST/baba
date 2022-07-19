require_relative "instance"
require_relative "runtime_error"

class Baba
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

      if name == "new"
        method = @klass.method(name)
        return RubyFunction.new(method, proc do |ret|
                 @object = ret
                 @methods = ret.methods.map { |m| m.to_s }
               end)
      end

      if name == "array_get" # This is not the best idea but it works
        if @methods.include?("[]")
          method = klass.method("[]")
          return RubyFunction.new(method)
        end
      end

      if name == "array_set"
        if @methods.include?("[]=")
          method = klass.method("[]=")
          return RubyFunction.new(method)
        end
      end

      if @methods.include?(name)
        method = klass.method(name)
        return RubyFunction.new(method)
      end

      raise BabaRuntimeError.new(name, "Undefined method #{name} for #{@klass}.")
    end

    def []=(name, value)
      klass = if @object.nil?
          @klass
        else
          @object
        end

      if @methods.include?[name.lexme + "="]
        method = klass.method(name + "=")
        method.call(value)
      else
        raise BabaRuntimeError.new(name, "Undefined method #{name.lexme}= for #{@klass}.")
      end
    end

    def to_s
      "<Ruby #{@klass}: #{@object}>"
    end
  end
end
