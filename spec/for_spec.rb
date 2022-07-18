require_relative "../lib/baba"

class ForTest
  describe "Testing for" do
    before do
      @baba = Baba.new
    end

    it "should do nothing" do
      @baba.run(%Q(
        for ,, {
          break
        }
      ))
      expect(@baba.running?).to eq(false)
    end

    it "should skip once" do
      @baba.run(%Q(
        for var i = 0, i <= 1, i = i + 1 {
          if i == 0 {
            next
          }
          yield i
        }
      ))
      expect(@baba.yielded_value).to eq(1)
    end
  end
end
