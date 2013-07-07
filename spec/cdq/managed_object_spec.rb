
module CDQ
  describe "CDQ Managed Object" do

    before do
      MotionData.setupCoreDataStack

      class << self
        include CDQ
      end
    end

    after do
      MotionData.resetCoreDataStack
    end

    it "provides a cdq class method" do
      Writer.cdq.class.should == CDQTargetedQuery
    end

    it "has a where method" do
      Writer.where(:name).eq('eecummings').class.should == CDQTargetedQuery
    end

    it "has a sort_by method" do
      Writer.sort_by(:name).class.should == CDQTargetedQuery
    end

    it "has a first method" do
      eec = cdq(Writer).create(name: 'eecummings')
      Writer.first.should == eec
    end

    it "has an all method" do
      eec = cdq(Writer).create(name: 'eecummings')
      Writer.all.array.should == [eec]
    end

    it "can save scopes" do
      class Writer
        scope :eecummings, where(:name).eq('eecummings')
        scope :edgaralpoe, where(:name).eq('edgar allen poe')
      end
      eec = cdq(Writer).create(name: 'eecummings')
      poe = cdq(Writer).create(name: 'edgar allen poe')
      Writer.eecummings.array.should == [eec]
      Writer.edgaralpoe.array.should == [poe]
      Writer.cdq.eecummings.array.should == [eec]
      Writer.cdq.edgaralpoe.array.should == [poe]
    end
  end
end
