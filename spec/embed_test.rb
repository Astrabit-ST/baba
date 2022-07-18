require_relative "../lib/baba"

baba = Baba.new
baba.run <<-EOS
for var i = 0, i < 10, i = i + 1 {
  yield i
}
EOS

while baba.yielded?
  puts baba.yielded_value
  baba.resume
end
