require_relative "parser"

class Baba
  attr_accessor :execution_limit

  def check_running
    raise "Baba is not running yet!" unless running?
  end

  def running?
    return false unless @interpreter
    @interpreter.running?
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
end
