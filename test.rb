require_relative "lexer"
require_relative "parser"

parser = BabaParser.new
statements = parser.scan_str(%Q(
var a = 1
switch a {
  when 1 {
    yield "a"
  }
  when 2 {
    yield "b"
  }
  else {
    yield "c"
  }
}
).chomp)

require "amazing_print"

ap statements, { object_id: false, raw: true }
