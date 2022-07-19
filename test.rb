require_relative "lib/baba"
require "debug"

b = Baba.new
b.run File.read("test.baba")

while b.yielded?
  puts b.yielded_value
  binding.break
  b.resume
end
