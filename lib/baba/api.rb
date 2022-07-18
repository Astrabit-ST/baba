require_relative "parser"

class Baba
  attr_accessor :execution_limit

  def check_running
    raise "Baba is not running yet!" unless @interpreter
  end

  def yielded?
    check_running
    @interpreter.yielded
  end

  def yielded_value
    check_running
    @interpreter.yielded_value
  end

  def resume
    check_running
    @interpreter.resume
  end

  def reset
    @interpreter = Interpreter.new
    @interpreter.execution_limit = @execution_limit
    @parser = BabaParser.new
  end
end
