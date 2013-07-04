
module CDQ
  describe "CDQ Query" do

    it "creates a scope with a simple true predicate" do
      @scope = CDQQuery.new
      @scope.predicate.should == nil
      @scope.limit.should == nil
      @scope.offset.should == nil
    end

    it "can set a limit on a scope" do
      @scope = CDQQuery.new(limit: 1)
      @scope.limit.should == 1
      @scope.offset.should == nil
    end

    it "can set a offset on a scope" do
      @scope = CDQQuery.new(offset: 1)
      @scope.limit.should == nil
      @scope.offset.should == 1
    end

    it "can 'and' itself with another scope" do
      @scope = CDQQuery.new(limit: 1, offset: 1)
      @other = CDQQuery.new(predicate: NSPredicate.predicateWithValue(false), limit: 2)
      @compound = @scope.and(@other)
      @compound.predicate.should == NSPredicate.predicateWithValue(false)
      @compound.limit.should == 2
      @compound.offset.should == 1
    end

    it "can 'and' itself with an NSPredicate" do
      @scope = CDQQuery.new
      @compound = @scope.and(NSPredicate.predicateWithValue(false))
      @compound.predicate.should == NSPredicate.predicateWithValue(false)
    end

    it "starts a partial predicate when 'and'-ing a symbol" do
      @scope = CDQQuery.new
      ppred = @scope.and(:name)
      ppred.class.should == CDQPartialPredicate
      ppred.key.should == :name
    end

    it "can 'or' itself with another scope" do
      @scope = CDQQuery.new(limit: 1, offset: 1)
      @other = CDQQuery.new(predicate: NSPredicate.predicateWithValue(false), limit: 2)
      @compound = @scope.or(@other)
      @compound.predicate.should == NSPredicate.predicateWithValue(false)
      @compound.limit.should == 2
      @compound.offset.should == 1
    end

    it "can 'or' itself with an NSPredicate" do
      @scope = CDQQuery.new
      @compound = @scope.or(NSPredicate.predicateWithValue(false))
      @compound.predicate.should == NSPredicate.predicateWithValue(false)
    end

    it "can sort by a key" do
      @scope = CDQQuery.new
      @scope.sort_by(:name).sort_descriptors.should == [
        NSSortDescriptor.sortDescriptorWithKey('name', ascending: true)
      ]
    end

    it "can sort descending" do
      @scope = CDQQuery.new
      @scope.sort_by(:name, :desc).sort_descriptors.should == [
        NSSortDescriptor.sortDescriptorWithKey('name', ascending: false)
      ]
    end

    it "can chain sorts" do
      @scope = CDQQuery.new
      @scope.sort_by(:name).sort_by(:title).sort_descriptors.should == [
        NSSortDescriptor.sortDescriptorWithKey('name', ascending: true),
        NSSortDescriptor.sortDescriptorWithKey('title', ascending: true)
      ]
    end

    it "handles complex examples" do
      scope1 = CDQQuery.new
      scope2 = scope1.where(CDQQuery.new.where(:name).ne('bob', NSCaseInsensitivePredicateOption).or(:amount).gt(42).sort_by(:name))
      scope3 = scope1.where(CDQQuery.new.where(:enabled).eq(true).and(:'job.title').ne(nil).sort_by(:amount, :desc))

      scope4 = scope3.where(scope2)
      scope4.predicate.predicateFormat.should == '(enabled == 1 AND job.title != nil) AND (name !=[c] "bob" OR amount > 42)'
      scope4.sort_descriptors.should == [
        NSSortDescriptor.alloc.initWithKey('amount', ascending:false),
        NSSortDescriptor.alloc.initWithKey('name', ascending:true)
      ]
    end

    it "can make a new scope with a new limit" do:w
    @scope = CDQQuery.new
    new_scope = @scope.limit(1)

    new_scope.limit.should == 1
    new_scope.offset.should == nil
  end

end
end
