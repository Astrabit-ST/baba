require_relative "tokens"
require_relative "token"
require_relative "error"

class Baba
  class Scanner
    attr_reader :source, :tokens

    def initialize(source)
      @source = source.strip
      @tokens = []

      @line = 1
      @current = 0
      @start = 0
    end

    def eof?
      @current >= @source.length
    end

    def scan_tokens
      until eof?
        # We are at the next lexeme
        @start = @current
        scan_token()
      end

      add_token(EOF)
      return @tokens
    end

    def add_token(type, literal = nil)
      text = @source[@start...@current]
      @tokens << Token.new(type, text, literal, @line)
    end

    def advance
      @current += 1
      return @source[@current - 1]
    end

    def match(expected)
      return false if eof?
      return false if @source[@current] != expected

      @current += 1
      return true
    end

    def peek()
      return "\0" if eof?
      return source[@current]
    end

    def peek_next()
      return "\0" if (@current + 1 >= @source.length)
      @source[@current + 1]
    end

    def digit?(c)
      !!(c =~ /\d/)
    end

    def alpha?(c)
      !!(c =~ /([a-z]|[A-Z]|_)/)
    end

    def alphanumeric?(c)
      alpha?(c) || digit?(c)
    end

    def scan_token
      c = advance()
      case c
      when "("
        add_token(LEFT_PAREN)
      when ")"
        add_token(RIGHT_PAREN)
      when ","
        add_token(COMMA)
      when "-"
        add_token(MINUS)
      when "+"
        add_token(PLUS)
      when "*"
        add_token(STAR)
      when "/"
        add_token(SLASH)
      when "%"
        add_token(MODULO)
      when ";"
        add_token(SEMICOLON)
      when ":"
        add_token(COLON)
      when "."
        add_token(DOT)
      when "!"
        add_token(match("=") ? NOT_EQUAL : NOT)
      when "<"
        add_token(match("=") ? LESS_EQUAL : LESS)
      when ">"
        add_token(match("=") ? GREATER_EQUAL : GREATER)
      when "="
        add_token(match("=") ? EQUAL_EQUAL : EQUAL)
      when "&"
        if match("&")
          add_token(AND)
        else
          error(c)
        end
      when "|"
        if match("|")
          add_token(OR)
        else
          error(c)
        end
      when "#"
        while peek() != "\n" && !eof?
          advance()
        end
      when " "
      when "\r"
        @line += 1
      when "\t"
        @line += 1
      when "\n"
        @line += 1
      when '"'
        string()
      else
        if digit?(c)
          number()
        elsif alpha?(c)
          identifier()
        else
          error(c)
        end
      end
    end

    def error(c)
      Baba.scanner_error(@line, "Unexpected character '#{c}'", @source, @current)
    end

    def identifier()
      while alphanumeric?(peek())
        advance()
      end

      text = @source[@start...@current]
      type = KEYWORDS[text]
      type = IDENTIFIER if type.nil?

      add_token(type)
    end

    def string()
      while peek() != '"' && !eof?
        @line += 1 if peek() == "\n"
        advance()
      end

      if eof?
        Baba.scanner_error(@line, "Unterminated string", @source, @start)
      end

      advance()

      value = @source[(@start + 1)..(@current - 2)]
      add_token(STRING, value)
    end

    def number()
      while digit?(peek())
        advance()
      end

      if peek() == "." && digit?(peek_next())
        advance()
        while digit?(peek())
          advance()
        end
      end

      add_token(NUMBER, @source[@start...@current].to_f)
    end
  end
end
