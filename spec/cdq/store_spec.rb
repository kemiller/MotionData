
module CDQ

  describe "CDQ Store Manager" do

    it "can set up a store coordinator" do
      @sm = CDQStoreManager.new(name: "CDQApp", model: MotionData.managedObjectModel)
      @sm.current.should != nil
      @sm.current.class.should == NSPersistentStoreCoordinator
    end

    it "can set up a store coordinator with default name" do
      @sm = CDQStoreManager.new(model: MotionData.managedObjectModel)
      @sm.current.should != nil
      @sm.current.class.should == NSPersistentStoreCoordinator
    end

  end

end
