
module CDQ

  describe "CDQ Object" do

    before do
      CDQ.cdq.setup

      class << self
        include CDQ
      end
    end

    after do
      CDQ.cdq.reset!
    end

    it "should have a context method" do
      cdq.contexts.class.should == CDQContextManager
    end

  end

end
