# frozen_string_literal: true

require_relative "baba/version"
require_relative "baba/run"
require_relative "baba/interpreter"

class Baba
  @@had_error = false

  def initialize
    @interpreter = Interpreter.new
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
end

Baba.new.main
