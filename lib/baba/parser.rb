require_relative "token"
require_relative "tokens"
require_relative "error"
require_relative "stmt"
require_relative "expr"

class Baba
  class Parser
    class ParserError < RuntimeError
    end

    attr_reader :tokens, :current

    def initialize(tokens)
      @tokens = tokens
      @current = 0
    end

    def parse
      statements = []

      while !eof?
        statements << declaration()
      end

      statements
    end

    def expression
      assignment()
    end

    def declaration
      begin
        return class_declaration() if match(THING)
        return function("function") if match(DOES)
        return var_declaration() if match(VAR)

        return statement()
      rescue ParserError => error
        synchronize()
        return nil
      end
    end

    def class_declaration
      name = consume(IDENTIFIER, "Expected class name.")

      superclass = if match(LESS)
          consume(IDENTIFIER, "Expected superclass name.")
          Expr::Variable.new(previous())
        end

      consume(COLON, "Expected ':' or '{' before class body.")

      methods = []
      until check(KEND) || eof?
        consume(DOES, "Expected 'does' before method declaration.")
        methods << function("method")
      end

      consume(KEND, "Expected 'end' or '}' after class body.")

      Stmt::Class.new(name, superclass, methods)
    end

    def var_declaration
      name = consume(IDENTIFIER, "Expected variable name")

      initializer = nil
      initializer = expression() if match(EQUAL)

      Stmt::Var.new(name, initializer)
    end

    def statement
      return for_statement() if match(FOR)
      return if_statement() if match(IF)
      return return_statement() if match(RETURN)
      return while_statement() if match(WHILE)
      return yield_statement() if match(YIELD)
      return Stmt::Block.new(block()) if match(COLON)
      return Stmt::Include.new(previous(), expression()) if match(INCLUDE)

      return expression_statement()
    end

    def for_statement
      initializer = if check(COMMA)
          nil
        elsif match(VAR)
          var_declaration()
        else
          expression_statement()
        end
      consume(COMMA, "Expected ',' after loop initializer")

      condition = unless check(COMMA)
          expression()
        else
          nil
        end
      consume(COMMA, "Expected ',' after loop condition")

      increment = unless check(COLON)
          expression()
        else
          nil
        end

      body = statement()

      unless increment.nil?
        body = Stmt::Block.new([body, Stmt::Expression.new(increment)])
      end

      if condition.nil?
        condition = Expr::Literal.new(true)
      end

      body = Stmt::While.new(condition, body)

      unless initializer.nil?
        body = Stmt::Block.new([initializer, body])
      end

      body
    end

    def if_statement
      condition = expression()

      then_branch = statement()
      else_branch = nil
      else_branch = statement() if match(ELSE)

      return Stmt::If.new(condition, then_branch, else_branch)
    end

    def return_statement
      keyword = previous()

      value = if match(SEMICOLON)
          nil
        else
          expression()
        end

      Stmt::Return.new(keyword, value)
    end

    def while_statement
      condition = expression()
      body = statement()

      return Stmt::While.new(condition, body)
    end

    def yield_statement
      keyword = previous()

      value = if match(SEMICOLON)
          nil
        else
          expression()
        end

      Stmt::Yield.new(keyword, value)
    end

    def expression_statement
      expr = expression()
      Stmt::Expression.new(expr)
    end

    def function(kind)
      name = consume(IDENTIFIER, "Expected #{kind} name.")
      consume(LEFT_PAREN, "Expected '(' after #{kind} + name.")
      parameters = []
      unless check(RIGHT_PAREN)
        loop do
          parameters << consume(IDENTIFIER, "Expected parameter name.")
          break unless match(COMMA)
        end
      end
      consume(RIGHT_PAREN, "Expected ')' after parameters.")

      consume(COLON, "Expected ':' before #{kind} body.")
      body = block()
      Stmt::Function.new(name, parameters, body)
    end

    def block
      statements = []
      until check(KEND) || check(ELSE) || eof?
        statements << declaration()
      end

      unless check(ELSE)
        consume(KEND, "Expected 'end' after block.")
      end
      statements
    end

    def assignment
      expr = expr_or()

      if match(EQUAL)
        equals = previous()
        value = assignment()

        if expr.is_a?(Expr::Variable)
          name = expr.name
          return Expr::Assign.new(name, value)
        elsif expr.is_a?(Expr::Get)
          return Expr::Set.new(expr.object, expr.name, value)
        end

        error(equals, "Invalid assignment target.")
      end

      expr
    end

    def expr_or
      expr = expr_and()

      while match(OR)
        operator = previous()
        right = expr_and()
        expr = Expr::Logical.new(expr, operator, right)
      end

      expr
    end

    def expr_and
      expr = equality()

      while match(AND)
        operator = previous()
        right = equality()
        expr = Expr::Logical.new(expr, operator, right)
      end

      expr
    end

    def equality()
      expr = comparison()

      while match(NOT_EQUAL, EQUAL_EQUAL)
        operator = previous()
        right = comparison()
        expr = Expr::Binary.new(expr, operator, right)
      end

      return expr
    end

    def comparison()
      expr = term()

      while match(GREATER, GREATER_EQUAL, LESS, LESS_EQUAL)
        operator = previous()
        right = term()
        expr = Expr::Binary.new(expr, operator, right)
      end

      return expr
    end

    def term
      expr = factor()

      while match(MINUS, PLUS)
        operator = previous()
        right = factor()
        expr = Expr::Binary.new(expr, operator, right)
      end

      return expr
    end

    def factor
      expr = unary()

      while match(SLASH, STAR)
        operator = previous()
        right = unary()
        expr = Expr::Binary.new(expr, operator, right)
      end

      return expr
    end

    def unary
      if match(NOT, MINUS)
        operator = previous()
        right = unary()
        return Expr::Unary.new(operator, right)
      end

      return call()
    end

    def finish_call(callee)
      arguments = []
      unless check(RIGHT_PAREN)
        loop do
          arguments << expression()
          break unless match(COMMA)
        end
      end

      paren = consume(RIGHT_PAREN, "Expected ')' after arguments.")

      Expr::Call.new(callee, paren, arguments)
    end

    def call
      expr = primary()

      loop do
        if match(LEFT_PAREN)
          expr = finish_call(expr)
        elsif match(DOT)
          name = consume(IDENTIFIER, "Expected property name '.'.")
          expr = Expr::Get.new(expr, name)
        else
          break
        end
      end

      expr
    end

    def primary
      return Expr::Literal.new(false) if match(FALSE)
      return Expr::Literal.new(true) if match(TRUE)
      return Expr::Literal.new(nil) if match(BLANK)
      return Expr::Break.new(previous()) if match(BREAK)
      return Expr::Self.new(previous()) if match(SELF)

      if match(NUMBER, STRING)
        return Expr::Literal.new(previous.literal())
      end

      if match(SUPER)
        keyword = previous()
        consume(DOT, "Expected '.' after super.")
        method = consume(IDENTIFIER, "Expected super thing method name.")
        return Expr::Super.new(keyword, method)
      end

      if match(IDENTIFIER)
        return Expr::Variable.new(previous())
      end

      if match(LEFT_PAREN)
        expr = expression()
        consume(RIGHT_PAREN, "Expected ')' after expression.")
        return Expr::Grouping.new(expr)
      end

      raise error(peek(), "Expect expression.")
    end

    def match(*types)
      types.each do |type|
        if check(type)
          advance()
          return true
        end
      end

      false
    end

    def consume(type, message)
      return advance() if check(type)

      raise(error(peek(), message))
    end

    def check(type)
      return false if eof?
      peek().type == type
    end

    def advance
      @current += 1 if !eof?
      previous()
    end

    def eof?
      peek().type == EOF
    end

    def peek
      @tokens[@current]
    end

    def previous
      @tokens[@current - 1]
    end

    def error(token, message)
      Baba.parser_error(token, message)
      ParserError.new
    end

    BREAKING_TOKENS = [THING, DOES, VAR, FOR, IF, WHILE, RETURN, BREAK]

    def synchronize
      advance()
      until eof?
        break if previous().type == SEMICOLON
        break if BREAKING_TOKENS.include?(peek().type)

        advance()
      end
    end
  end
end
