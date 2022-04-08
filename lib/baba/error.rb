require_relative "tokens"

class Baba
  def self.scanner_error(line, what, contents = nil, character = nil)
    line_contents = nil
    line_character = nil
    unless contents.nil?
      begin
        line_contents = contents.split("\n")[line - 1]
        unless character.nil?
          line_character = character - contents.split("\n")[0..line].join.length
        end
      rescue ArgumentError => e
        warn e.message
      end
      line_character = nil if line_character.negative?
    end
    report(line, what, line_contents, line_character)
  end

  def self.parser_error(token, what)
    if (token.type == EOF)
      report(token.line, "at_end #{what}")
    else
      report(token.line, "at '#{token.lexeme}', #{what}")
    end
  end

  def self.runtime_error(error)
    if error.token.nil?
      report(0, error.message)
      return
    end
    report(error.token.line, error.message)
  end

  def self.report(line, what, line_contents = nil, character = nil)
    warn "Error: #{what}\n"
    warn "#{line} | #{line_contents}" if line_contents
    warn "#{line} | " + ("~" * character) + "^ HERE" if character && line_contents
    warn "*" * 30

    @@had_error = true
  end

  def self.had_error
    @@had_error
  end
end
