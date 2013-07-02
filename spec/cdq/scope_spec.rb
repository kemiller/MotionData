
describe "CDQ Scope" do

  it "creates a scope with a simple true predicate" do
    @scope = CDQ::Scope.new
    @scope.predicate.should == NSPredicate.predicateWithValue(true)
  end
  
end
