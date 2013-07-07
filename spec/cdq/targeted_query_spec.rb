
module CDQ
  describe "CDQ Targeted Queries" do

    before do
      MotionData.setupCoreDataStack

      class << self
        include CDQ
      end
    end

    after do
      MotionData.resetCoreDataStack
    end

    it "reflects a base state" do
      tq = CDQTargetedQuery.new(Author.entityDescription, Author)
      tq.count.should == 0
      tq.array.should == []
    end

    it "can count objects" do
      tq = CDQTargetedQuery.new(Author.entityDescription, Author)
      Author.new(name: "eecummings")
      tq.count.should == 1
      Author.new(name: "T. S. Eliot")
      tq.count.should == 2
    end

    it "can fetch objects" do
      tq = CDQTargetedQuery.new(Author.entityDescription, Author)
      eecummings = Author.new(name: "eecummings")
      tseliot = Author.new(name: "T. S. Eliot")
      tq.array.sort_by(&:name).should == [tseliot, eecummings]
    end

    it "can create objects" do
      maya = cdq(Author).create(name: "maya angelou")
      cdq(Author).where(:name).eq("maya angelou").first.should == maya
    end

    describe "CDQ Targeted Queries with data" do

      before do
        @tq = cdq(Author)
        @eecummings = Author.new(name: "eecummings")
        @tseliot = Author.new(name: "T. S. Eliot")
        @dante = Author.new(name: "dante")
        MotionData.saveAll
      end

      it "performs a sorted fetch" do
        @tq.sort_by(:name).array.should == [@tseliot, @dante, @eecummings]
      end

      it "performs a limited fetch" do
        @tq.sort_by(:name).limit(1).array.should == [@tseliot]
      end

      it "performs an offset fetch" do
        @tq.sort_by(:name).offset(1).array.should == [@dante, @eecummings]
        @tq.sort_by(:name).offset(1).limit(1).array.should == [@dante]
      end

      it "performs a restricted search" do
        @tq.where(:name).eq("dante").array.should == [@dante]
      end

      it "gets the first entry" do
        @tq.sort_by(:name).first.should == @tseliot
      end

      it "gets entries by index" do
        @tq.sort_by(:name)[0].should == @tseliot
        @tq.sort_by(:name)[1].should == @dante
        @tq.sort_by(:name)[2].should == @eecummings
      end

      it "can iterate over entries" do
        entries = [@tseliot, @dante, @eecummings]

        @tq.sort_by(:name).each do |e|
          e.should == entries.shift
        end
      end

      it "can map over entries" do
        entries = [@tseliot, @dante, @eecummings]

        @tq.sort_by(:name).map { |e| e }.should == entries
      end

      it "can create a named scope" do
        @tq.scope :two_sorted_by_name, @tq.sort_by(:name).limit(2)
        @tq.two_sorted_by_name.array.should == [@tseliot, @dante]
      end
    end


  end
end