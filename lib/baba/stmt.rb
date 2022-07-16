class Baba
  module Stmt
    class Block
      attr_reader :statements

      def initialize(statements)
        @statements = statements
      end

      def accept(visitor)
        visitor.visit_block_stmt(self)
      end
    end

    class Class
      attr_reader :name, :superclass, :methods

      def initialize(name, superclass, methods)
        @name = name; @superclass = superclass; @methods = methods
      end

      def accept(visitor)
        visitor.visit_class_stmt(self)
      end
    end

    class Expression
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_expression_stmt(self)
      end
    end

    class Function
      attr_reader :name, :params, :body

      def initialize(name, params, body)
        @name = name; @params = params; @body = body
      end

      def accept(visitor)
        visitor.visit_function_stmt(self)
      end
    end

    class If
      attr_reader :condition, :then_branch, :else_branch

      def initialize(condition, then_branch, else_branch)
        @condition = condition; @then_branch = then_branch; @else_branch = else_branch
      end

      def accept(visitor)
        visitor.visit_if_stmt(self)
      end
    end

    class Include
      attr_reader :keyword, :expression

      def initialize(keyword, expression)
        @keyword = keyword; @expression = expression
      end

      def accept(visitor)
        visitor.visit_include_stmt(self)
      end
    end

    class Return
      attr_reader :keyword, :value

      def initialize(keyword, value)
        @keyword = keyword; @value = value
      end

      def accept(visitor)
        visitor.visit_return_stmt(self)
      end
    end

    class Var
      attr_reader :name, :initializer

      def initialize(name, initializer)
        @name = name; @initializer = initializer
      end

      def accept(visitor)
        visitor.visit_var_stmt(self)
      end
    end

    class While
      attr_reader :condition, :body

      def initialize(condition, body)
        @condition = condition; @body = body
      end

      def accept(visitor)
        visitor.visit_while_stmt(self)
      end
    end

    class Yield
      attr_reader :keyword, :value

      def initialize(keyword, value)
        @keyword = keyword; @value = value
      end

      def accept(visitor)
        visitor.visit_yield_stmt(self)
      end
    end
  end
end
