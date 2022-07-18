class Baba
  class BabaRuntimeError < RuntimeError
    def initialize(message)
      super(message)
    end
  end
end
