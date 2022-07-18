class Baba
  def self.parser_error(token, what)
    report(0, "'#{token}', #{what}")
  end

  def self.runtime_error(error)
    if error.token.nil?
      report(0, error.message)
      return
    end
    report(error.token.line, error.message)
  end

  def self.report(line, what, line_contents = nil, character = nil)
    warn "Error at line #{line}: #{what}\n"
    warn "#{line} | #{line_contents}" if line_contents
    warn "#{line} | " + ("~" * character) + "^ HERE" if character && line_contents
    warn "*" * 30

    @@had_error = true
  end

  def self.had_error
    @@had_error
  end
end
