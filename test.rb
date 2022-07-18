require_relative "lexer"
require_relative "parser"

parser = BabaParser.new
#parser.instance_variable_set(:@yydebug, true)
statements = parser.scan_str(%Q(
1 * 2 - 3 + 4 / 5 % 6
a.b().c.d = 1
).chomp)

require "amazing_print"

ap statements, { object_id: false, raw: true }
