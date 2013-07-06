
module CDQ

  describe "CDQ Context Manager" do

    before do
      @cc = CDQContextManager.new(store: MotionData::StoreCoordinator.default)
      @context = NSManagedObjectContext.alloc.initWithConcurrencyType(NSPrivateQueueConcurrencyType)
    end

    it "can push a NSManagedObjectContext onto its stack" do
      @cc.push(@context)
      @cc.current.should == @context
      @cc.all.should == [@context]
    end

    it "can pop a NSManagedObjectContext off its stack" do
      @cc.push(@context)
      @cc.pop.should == @context
      @cc.current.should == nil
      @cc.all.should == []
    end

    it "pushes temporarily if passed a block" do
      @cc.push(@context) do
        @cc.current.should == @context
      end
      @cc.current.should == nil
    end

    it "pops temporarily if passed a block" do
      @cc.push(@context)
      @cc.pop do
        @cc.current.should == nil
      end
      @cc.current.should == @context
    end

  end

end
