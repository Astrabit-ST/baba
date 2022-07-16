require_relative "tokens"
require_relative "runtime_error"
require_relative "error"
require_relative "environment"
require_relative "callable"
require_relative "function"
require_relative "class"
require_relative "instance"

require_relative "scanner"
require_relative "parser"
require_relative "resolver"

class Baba
  class Return < RuntimeError
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  class Break < RuntimeError
  end

  class Interpreter
    attr_reader :globals
    attr_reader :yielded, :yielded_value
    attr_accessor :execution_limit

    def initialize(environment = Environment.new, loaded_files = [])
      @globals = environment
      @environment = @globals
      @locals = {}
      @loaded_files = loaded_files

      @execution_count = 0
    end

    def interpret(statements)
      @fiber = Fiber.new do
        begin
          statements.each { |s| execute(s) }
        rescue BabaRuntimeError => error
          Baba.runtime_error(error)
        end
      end
      @fiber.resume
    end

    def resume
      raise BabaRuntimeError.new(nil, "Baba is not currently executing code.") unless @fiber.alive?
      @fiber.resume
    end

    def running?
      @fiber.alive?
    end

    def resolve(expr, depth)
      @locals[expr] = depth
    end

    def evaluate(expr)
      expr.accept(self)
    end

    def execute(stmt)
      begin
        unless @execution_limit.nil?
          @execution_count += 1
          if @execution_count > @execution_limit
            @yielded = true

            Fiber.yield

            @yielded = false
            @execution_count = 0
          end
        end

        stmt.accept(self)
      rescue SystemStackError
        raise BabaRuntimeError.new(nil, "Stack level too deep (wild recursive method?)")
      end
    end

    def execute_block(statements, environment)
      previous = @environment
      begin
        @environment = environment

        statements.each { |s| execute(s) }
      ensure
        @environment = previous
      end
    end

    def visit_block_stmt(stmt)
      execute_block(stmt.statements, Environment.new(@environment))
    end

    def visit_break_expr(expr)
      raise Break.new
    end

    def visit_class_stmt(stmt)
      superclass = nil
      unless stmt.superclass.nil?
        superclass = evaluate(stmt.superclass)
        unless superclass.is_a?(BabaClass)
          raise BabaRuntimeError.new(stmt.superclass.name, "Super thing must be a class.")
        end
      end

      @environment.define(stmt.name.lexeme, nil)

      unless stmt.superclass.nil?
        @environment = Environment.new(@environment)
        @environment.define("super", superclass)
      end

      methods = {}
      stmt.methods.each do |method|
        function = Function.new(method, @environment)
        methods[method.name.lexeme] = function
      end

      klass = BabaClass.new(stmt.name.lexeme, superclass, methods)

      unless superclass.nil?
        @environment = @environment.enclosing
      end

      @environment[stmt.name] = klass
    end

    def visit_expression_stmt(stmt)
      evaluate(stmt.expression)
    end

    def visit_function_stmt(stmt)
      function = Function.new(stmt, @environment)
      @environment.define(stmt.name.lexeme, function)
    end

    def visit_if_stmt(stmt)
      if truthy?(evaluate(stmt.condition))
        execute(stmt.then_branch)
      elsif !stmt.else_branch.nil?
        execute(stmt.else_branch)
      end
      nil
    end

    def visit_include_stmt(stmt)
      string = evaluate(stmt.expression)

      string += ".baba" unless File.exist?(string)
      string = File.join(__dir__, string) unless File.exist?(string) # Standard library
      unless File.exist?(string)
        raise BabaRuntimeError.new(stmt.keyword, "Unable to find #{evaluate(stmt.expression)}.")
      end

      return if @loaded_files.include?(string) # Don't load the same file multiple times! We could get weird stack level wackiness
      @loaded_files << string

      # TODO
    end

    def visit_return_stmt(stmt)
      value = unless stmt.value.nil?
          evaluate(stmt.value)
        end

      raise Return.new(value)
    end

    def visit_var_stmt(stmt)
      value = nil
      if (stmt.initializer != nil)
        value = evaluate(stmt.initializer)
      end

      @environment.define(stmt.name.lexeme, value)
      value
    end

    def visit_while_stmt(stmt)
      while truthy?(evaluate(stmt.condition))
        begin
          execute(stmt.body)
        rescue Break
          break
        end
      end
      nil
    end

    def visit_yield_stmt(stmt)
      value = evaluate(stmt.value)
      @yielded = true
      @yielded_value = value

      Fiber.yield

      @yielded = false
      @yielded_value = nil
    end

    def visit_assign_expr(expr)
      value = evaluate(expr.value)

      distance = @locals[expr]
      unless distance.nil?
        @environment.assign_at(distance, expr.name, value)
      else
        @globals[expr.name] = value
      end

      value
    end

    def visit_binary_expr(expr)
      left = evaluate(expr.left)
      right = evaluate(expr.right)

      case expr.operator.type
      when MINUS
        return left - right
      when SLASH
        return left / right
      when STAR
        return left * right
      when PLUS
        return left + right
      when GREATER
        return left > right
      when GREATER_EQUAL
        return left >= right
      when LESS
        return left < right
      when LESS_EQUAL
        return left <= right
      when NOT_EQUAL
        return !equal?(left, right)
      when EQUAL_EQUAL
        return equal?(left, right)
      end

      return nil
    end

    def visit_call_expr(expr)
      callee = evaluate(expr.callee)

      arguments = expr.arguments.map { |a| evaluate(a) }

      unless callee.kind_of?(Callable)
        raise BabaRuntimeError.new(expr.paren, "Can only call callable objects.")
      end
      if arguments.size != callee.arity
        raise BabaRuntimeError.new(expr.paren, "Expected #{callee.arity} arguments, got #{arguments.size}.")
      end
      callee.call(self, arguments)
    end

    def visit_get_expr(expr)
      object = evaluate(expr.object)
      if object.is_a?(Instance)
        return object[expr.name]
      end

      raise BabaRuntimeError.new(expr.name, "Only instances have properties.")
    end

    def visit_literal_expr(expr)
      expr.value
    end

    def visit_logical_expr(expr)
      left = evaluate(expr.left)

      if expr.operator.type == OR
        return left if truthy?(left)
      else
        return left if !truthy?(left)
      end

      return evaluate(expr.right)
    end

    def visit_self_expr(expr)
      look_up_variable(expr.keyword, expr)
    end

    def visit_set_expr(expr)
      object = evaluate(expr.object)

      unless object.is_a?(Instance)
        raise BabaRuntimeError.new(expr.name, "Only instances have fields.")
      end

      value = evaluate(expr.value)
      object[expr.name] = value
      return value
    end

    def visit_super_expr(expr)
      distance = @locals[expr]
      superclass = @environment.get_at(distance, "super")

      object = @environment.get_at(distance - 1, "self")

      method = superclass.find_method(expr.method.lexeme)

      if method.nil?
        raise BabaRuntimeError.new(expr.method, "Undefined property #{expr.method.lexeme}.")
      end

      method.bind(object)
    end

    def visit_unary_expr(expr)
      right = evaluate(expr.right)

      case expr.operator.type
      when MINUS
        return -(right.to_f)
      when NOT
        return !truthy?(right)
      end

      return nil
    end

    def visit_variable_expr(expr)
      look_up_variable(expr.name, expr)
    end

    def look_up_variable(name, expr)
      distance = @locals[expr]
      unless distance.nil?
        return @environment.get_at(distance, name.lexeme)
      else
        return @globals[name]
      end
    end

    def truthy?(object)
      !!object
    end

    def equal?(a, b)
      a == b
    end

    def visit_grouping_expr(expr)
      evaluate(expr.expression)
    end
  end
end
