class Baba
  class Interpreter
    attr_accessor :execution_limit

    def initialize

      # Default standard library
      include_file("std/string")
      include_file("std/number")
      include_file("std/boolean")
      include_file("std/object")
    end

    def interpret(statements)
    end

    def include_file(path)
    end
  end
end
