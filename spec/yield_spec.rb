require_relative "../lib/baba"

class YieldTest
  describe "Testing yield" do
    before do
      @baba = Baba.new
    end

    it "should yield 1.5" do
      @baba.run("yield 1.5")
      expect(@baba.yielded_value).to eq(1.5)
    end

    it "should yield" do
      @baba.run("yield")
      expect(@baba.yielded?).to eq(true)
    end

    it "should resume" do
      @baba.run("yield\nyield")
      @baba.resume
      expect(@baba.yielded?).to eq(true)
    end
  end
end
