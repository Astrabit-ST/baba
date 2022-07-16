require_relative "../lib/baba"

baba = Baba.new
baba.execution_limit = 100
baba.run <<-EOS
does main():
  var i = 0
  while i < 1000:
    i = i + 1
  end
end

main()
EOS

i = 1
while baba.yielded?
  puts i
  i += 1
  baba.resume
end
puts i
