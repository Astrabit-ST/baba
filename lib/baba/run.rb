require_relative "scanner"
require_relative "parser"
require_relative "resolver"
require "pp"

class Baba
  def run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens
    parser = Parser.new(tokens)

    statements = parser.parse

    return if @@had_error

    resolver = Resolver.new(@interpreter)
    resolver.resolve(statements)

    return if @@had_error

    @interpreter.interpret(statements)
  end
end
