require_relative "../lib/baba"

baba = Baba.new
baba.run <<-EOS
does main():
  var i = 0
  while i < 10:
    i = i + 1

    if i % 2 == 0:
      next
    end

    yield i
  end
end

main()
EOS

while baba.yielded?
  puts baba.yielded_value
  baba.resume
end
