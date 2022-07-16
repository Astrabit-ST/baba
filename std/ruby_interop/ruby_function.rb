require_relative "function"

class Baba
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
