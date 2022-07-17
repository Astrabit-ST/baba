class Baba
  class Resolver
    class FunctionType
      NONE = 0
      FUNCTION = 1
      METHOD = 2
      INIT = 3
    end

    class BreakableType
      NONE = 0
      WHILE = 1
    end

    class ClassType
      NONE = 0
      CLASS = 1
      SUBCLASS = 2
    end

    class SwitchType
      NONE = 0
      SWITCH = 1
    end

    def initialize(interpreter)
      @interpreter = interpreter
      @scopes = []
      @current_function = FunctionType::NONE
      @current_breakable = BreakableType::NONE
      @current_class = ClassType::NONE
      @current_switch = SwitchType::NONE
    end

    def resolve(statements)
      if statements.is_a?(Array)
        statements.each { |s| resolve(s) }
      else
        statements.accept(self)
      end
    end

    def resolve_function(function, type)
      enclosing_function = @current_function
      @current_function = type

      begin_scope()
      function.params.each do |p|
        declare(p)
        define(p)
      end
      resolve(function.body)
      end_scope()

      @current_function = enclosing_function
    end

    def begin_scope()
      @scopes << {}
    end

    def end_scope
      @scopes.pop
    end

    def declare(name)
      return if @scopes.empty?

      if @scopes.last.include?(name.lexeme)
        Baba.parser_error(name, "Already declared a variable with this name in this scope.")
      end

      @scopes.last[name.lexeme] = false
    end

    def define(name)
      return if @scopes.empty?
      @scopes.last[name.lexeme] = true
    end

    def resolve_local(expr, name)
      (0...(@scopes.size)).reverse_each do |i|
        scope = @scopes[i]
        if scope.include?(name.lexeme)
          @interpreter.resolve(expr, @scopes.size - 1 - i)
          break
        end
      end
    end

    def visit_block_stmt(stmt)
      begin_scope()
      resolve(stmt.statements)
      end_scope()
    end

    def visit_break_expr(expr)
      if @current_breakable == BreakableType::NONE
        Baba.parser_error(expr.keyword, "Can't break from a non-breakable statement.")
      end
    end

    def visit_next_expr(expr)
      if @current_breakable == BreakableType::NONE
        Baba.parser_error(expr.keyword, "Can't skip in a non-breakable statement.")
      end
    end

    def visit_class_stmt(stmt)
      enclosing_class = @current_class
      @current_class = ClassType::CLASS

      declare(stmt.name)
      define(stmt.name)

      if !stmt.superclass.nil? && stmt.superclass.name.lexeme == stmt.name.lexeme
        Baba.parser_error(stmt.superclass.name, "A thing cannot inherit from itself.")
      end

      unless stmt.superclass.nil?
        @current_class = ClassType::SUBCLASS
        resolve(stmt.superclass)

        begin_scope()
        @scopes.last["super"] = true
      end

      begin_scope()
      @scopes.last["self"] = true

      stmt.methods.each do |method|
        declaration = FunctionType::METHOD
        if method.name.lexeme == "init"
          declaration = FunctionType::INIT
        end
        resolve_function(method, declaration)
      end

      end_scope()

      unless stmt.superclass.nil?
        end_scope()
      end

      @current_class = enclosing_class
    end

    def visit_expression_stmt(stmt)
      resolve(stmt.expression)
    end

    def visit_if_stmt(stmt)
      resolve(stmt.condition)
      resolve(stmt.then_branch)
      resolve stmt.else_branch unless stmt.else_branch.nil?
    end

    def visit_include_stmt(stmt)
      resolve(stmt.expression)
    end

    def visit_switch_stmt(stmt)
      enclosing_switch = @current_switch
      @current_switch = SwitchType::SWITCH
      resolve(stmt.condition)
      stmt.cases.each do |case_|
        resolve(case_)
      end
      resolve(stmt.default) unless stmt.default.nil?
      @current_switch = enclosing_switch
    end

    def visit_when_stmt(stmt)
      if @current_switch == SwitchType::NONE
        Baba.parser_error(stmt.keyword, "Can't use 'when' outside of a switch.")
      end

      resolve(stmt.condition)
      resolve(stmt.body)
    end

    def visit_while_stmt(stmt)
      enclosing_break = @current_breakable
      @current_breakable = BreakableType::WHILE

      resolve(stmt.condition)
      resolve(stmt.body)

      @current_breakable = enclosing_break
    end

    def visit_yield_stmt(stmt)
      resolve(stmt.value)
    end

    def visit_return_stmt(stmt)
      if @current_function == FunctionType::NONE
        Baba.parser_error(stmt.keyword, "Can't return from top-level code.")
      end

      unless stmt.value.nil?
        if @current_function == FunctionType::INIT && !stmt.value.is_a?(Expr::Self)
          Baba.parser_error(stmt.keyword, "Can't return a non-self value from an initializer.")
        end

        resolve(stmt.value)
      end
    end

    def visit_function_stmt(stmt)
      declare(stmt.name)
      define(stmt.name)

      resolve_function(stmt, FunctionType::FUNCTION)
    end

    def visit_var_stmt(stmt)
      declare(stmt.name)
      unless stmt.initializer.nil?
        resolve(stmt.initializer)
      end
      define(stmt.name)
    end

    def visit_variable_expr(expr)
      if !@scopes.empty? && @scopes.last[expr.name.lexeme] == false
        Baba.parser_error(expr.name, "Can't read local variable in its own initializer.")
      end

      resolve_local(expr, expr.name)
    end

    def visit_assign_expr(expr)
      resolve(expr.value)
      resolve_local(expr, expr.name)
    end

    def visit_binary_expr(expr)
      resolve(expr.left)
      resolve(expr.right)
    end

    def visit_call_expr(expr)
      resolve(expr.callee)
      expr.arguments.each { |a| resolve(a) }
    end

    def visit_get_expr(expr)
      resolve(expr.object)
    end

    def visit_grouping_expr(expr)
      resolve(expr.expression)
    end

    def visit_literal_expr(expr)
    end

    def visit_logical_expr(expr)
      resolve(expr.left)
      resolve(expr.right)
    end

    def visit_self_expr(expr)
      if @current_class == ClassType::NONE
        Baba.parser_error(expr.keyword, "Can't use 'self' outside of a thing.")
      end

      resolve_local(expr, expr.keyword)
    end

    def visit_set_expr(expr)
      resolve(expr.value)
      resolve(expr.object)
    end

    def visit_super_expr(expr)
      if @current_class == ClassType::NONE
        Baba.parser_error(expr.keyword, "Can't use 'super' outside of a thing.")
      elsif @current_class == ClassType::CLASS
        Baba.parser_error(expr.keyword, "Can't use 'super' in a thing with no super thing.")
      end

      resolve_local(expr, expr.keyword)
    end

    def visit_unary_expr(expr)
      resolve(expr.right)
    end
  end
end
