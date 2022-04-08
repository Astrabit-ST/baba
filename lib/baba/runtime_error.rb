class Baba
  class BabaRuntimeError < RuntimeError
    attr_reader :token

    def initialize(token, message)
      super(message)
      @token = token
    end
  end
end
