
describe "CDQ Scope" do

  it "creates a scope with a simple true predicate" do
    @scope = CDQ::Scope.new
    @scope.predicate.should == NSPredicate.predicateWithValue(true)
    @scope.limit.should == nil
    @scope.offset.should == nil
  end

  it "can set a limit on a scope" do
    @scope = CDQ::Scope.new(limit: 1)
    @scope.limit.should == 1
    @scope.offset.should == nil
  end
  
  it "can set a offset on a scope" do
    @scope = CDQ::Scope.new(offset: 1)
    @scope.limit.should == nil
    @scope.offset.should == 1
  end

  it "can 'and' itself with another scope" do
    @scope = CDQ::Scope.new(limit: 1, offset: 1)
    @other = CDQ::Scope.new(predicate: NSPredicate.predicateWithValue(false), limit: 2)
    @compound = @scope.and(@other)
    @compound.predicate.should == NSCompoundPredicate.andPredicateWithSubpredicates(
      [NSPredicate.predicateWithValue(true),
       NSPredicate.predicateWithValue(false)]
    )
    @compound.limit.should == 2
    @compound.offset.should == 1
  end

  it "can 'and' itself with an NSPredicate" do
    @scope = CDQ::Scope.new
    @compound = @scope.and(NSPredicate.predicateWithValue(false))
    @compound.predicate.should == NSCompoundPredicate.andPredicateWithSubpredicates(
      [NSPredicate.predicateWithValue(true),
       NSPredicate.predicateWithValue(false)]
    )
  end

  it "can 'or' itself with another scope" do
    @scope = CDQ::Scope.new(limit: 1, offset: 1)
    @other = CDQ::Scope.new(predicate: NSPredicate.predicateWithValue(false), limit: 2)
    @compound = @scope.or(@other)
    @compound.predicate.should == NSCompoundPredicate.orPredicateWithSubpredicates(
      [NSPredicate.predicateWithValue(true),
       NSPredicate.predicateWithValue(false)]
    )
    @compound.limit.should == 2
    @compound.offset.should == 1
  end

  it "can 'or' itself with an NSPredicate" do
    @scope = CDQ::Scope.new
    @compound = @scope.or(NSPredicate.predicateWithValue(false))
    @compound.predicate.should == NSCompoundPredicate.orPredicateWithSubpredicates(
      [NSPredicate.predicateWithValue(true),
       NSPredicate.predicateWithValue(false)]
    )
  end

  it "can make a new scope with a new limit" do:w
    @scope = CDQ::Scope.new
    new_scope = @scope.limit(1)

    new_scope.limit.should == 1
    new_scope.offset.should == nil
  end
  
end
