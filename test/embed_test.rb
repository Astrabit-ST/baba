require_relative "../lib/baba"

baba = Baba.new
baba.run <<-EOS
if false:
else if false:
else:
  yield "hi"
end

var x = 0
while x < 5:
  switch x - 1:
    when 1:
      yield "a"
    end
    when 2:
      yield "b"
    end
    when 3:
      yield "c"
    end
  else:
    yield "no"
  end
  x = x + 1
end
EOS

while baba.yielded?
  puts baba.yielded_value
  baba.resume
end
