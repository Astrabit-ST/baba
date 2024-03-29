# frozen_string_literal: true

require_relative "baba/baba_vm"

class Baba
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
  end

  require "readline"

  def run_interactive
    prompt = "irbaba (#{"2.6.0"}) > "
    use_history = true
    while buf = Readline.readline(prompt, use_history)
      break if buf == "exit"

      run(buf)
      @@had_error = false
    end
  end
end
