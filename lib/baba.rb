# frozen_string_literal: true

require_relative "baba/version"
require_relative "baba/interpreter"
require_relative "baba/resolver"
require_relative "baba"
require_relative "baba/api"

class Baba
  @@had_error = false

  def initialize
    @interpreter = Interpreter.new
    @parser = BabaParser.new
  end

  def main
    case ARGV.length
    when 1
      run_file(ARGV[0])
    when 0
      run_interactive
    else
      puts "Usage: baba [file]"
    end
  end

  def run_file(path)
    f = File.open(path, "rb+")
    run(f.read)

    if @@had_error
      exit 1
    end
  end

  require "readline"

  def run_interactive
    prompt = "irbaba (#{VERSION}) > "
    use_history = true
    while buf = Readline.readline(prompt, use_history)
      break if buf == "exit"

      run(buf)
      @@had_error = false
    end
  end

  def run(source)
    @interpreter.execution_limit = @execution_limit

    begin
      statements = @parser.scan_str(source)
    rescue Racc::ParseError
      return
    end

    resolver = Resolver.new(@interpreter)
    resolver.resolve(statements)

    return if @@had_error

    @interpreter.interpret(statements)
  end
end
