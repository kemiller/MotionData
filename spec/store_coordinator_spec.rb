module MotionData

  describe StoreCoordinator do
    it "returns an in memory store with the given schema" do
      store = StoreCoordinator.inMemory(MotionData.managedObjectModel)
      store.managedObjectModel.should == MotionData.managedObjectModel
      store.persistentStores.first.type.should == NSInMemoryStoreType
    end
  end

end
