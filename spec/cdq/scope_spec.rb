
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

end
