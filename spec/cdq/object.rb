
module CDQ

  describe "CDQ Object" do

    before do
      MotionData.setupCoreDataStack

      class << self
        include CDQ
      end
    end

    after do
      MotionData.resetCoreDataStack
    end

    it "should have a context method" do
      cdq.context.class.should == CDQContextManager
    end

  end

end
