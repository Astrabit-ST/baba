class Baba
  module Expr
    class Assign
      attr_reader :name, :value

      def initialize(name, value)
        @name = name; @value = value
      end

      def accept(visitor)
        visitor.visit_assign_expr(self)
      end
    end

    class Binary
      attr_reader :left, :operator, :right

      def initialize(left, operator, right)
        @left = left; @operator = operator; @right = right
      end

      def accept(visitor)
        visitor.visit_binary_expr(self)
      end
    end

    class Break
      attr_reader :keyword

      def initialize(keyword)
        @keyword = keyword
      end

      def accept(visitor)
        visitor.visit_break_expr(self)
      end
    end

    class Call
      attr_reader :callee, :paren, :arguments

      def initialize(callee, paren, arguments)
        @callee = callee; @paren = paren; @arguments = arguments
      end

      def accept(visitor)
        visitor.visit_call_expr(self)
      end
    end

    class Get
      attr_reader :object, :name

      def initialize(object, name)
        @object = object; @name = name
      end

      def accept(visitor)
        visitor.visit_get_expr(self)
      end
    end

    class Grouping
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_grouping_expr(self)
      end
    end

    class Literal
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def accept(visitor)
        visitor.visit_literal_expr(self)
      end
    end

    class Logical
      attr_reader :left, :operator, :right

      def initialize(left, operator, right)
        @left = left; @operator = operator; @right = right
      end

      def accept(visitor)
        visitor.visit_logical_expr(self)
      end
    end

    class Next
      attr_reader :keyword

      def initialize(keyword)
        @keyword = keyword
      end

      def accept(visitor)
        visitor.visit_next_expr(self)
      end
    end

    class Self
      attr_reader :keyword

      def initialize(keyword)
        @keyword = keyword
      end

      def accept(visitor)
        visitor.visit_self_expr(self)
      end
    end

    class Super
      attr_reader :keyword, :method

      def initialize(keyword, method)
        @keyword = keyword; @method = method
      end

      def accept(visitor)
        visitor.visit_super_expr(self)
      end
    end

    class Set
      attr_reader :object, :name, :value

      def initialize(object, name, value)
        @object = object; @name = name; @value = value
      end

      def accept(visitor)
        visitor.visit_set_expr(self)
      end
    end

    class Unary
      attr_reader :operator, :right

      def initialize(operator, right)
        @operator = operator; @right = right
      end

      def accept(visitor)
        visitor.visit_unary_expr(self)
      end
    end

    class Variable
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def accept(visitor)
        visitor.visit_variable_expr(self)
      end
    end
  end
end
