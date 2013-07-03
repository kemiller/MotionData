
describe "CDQ Scope" do

  it "creates a scope with a simple true predicate" do
    @scope = CDQ::Scope.new
    @scope.predicate.should == nil
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
    @compound.predicate.should == NSPredicate.predicateWithValue(false)
    @compound.limit.should == 2
    @compound.offset.should == 1
  end

  it "can 'and' itself with an NSPredicate" do
    @scope = CDQ::Scope.new
    @compound = @scope.and(NSPredicate.predicateWithValue(false))
    @compound.predicate.should == NSPredicate.predicateWithValue(false)
  end

  it "starts a partial predicate when 'and'-ing a symbol" do
    @scope = CDQ::Scope.new
    ppred = @scope.and(:name)
    ppred.class.should == CDQ::PartialPredicate
    ppred.key.should == :name
  end

  it "can 'or' itself with another scope" do
    @scope = CDQ::Scope.new(limit: 1, offset: 1)
    @other = CDQ::Scope.new(predicate: NSPredicate.predicateWithValue(false), limit: 2)
    @compound = @scope.or(@other)
    @compound.predicate.should == NSPredicate.predicateWithValue(false)
    @compound.limit.should == 2
    @compound.offset.should == 1
  end

  it "can 'or' itself with an NSPredicate" do
    @scope = CDQ::Scope.new
    @compound = @scope.or(NSPredicate.predicateWithValue(false))
    @compound.predicate.should == NSPredicate.predicateWithValue(false)
  end

  it "can sort by a key" do
    @scope = CDQ::Scope.new
    @scope.sort_by(:name).sort_descriptors.should == [
      NSSortDescriptor.sortDescriptorWithKey('name', ascending: true)
    ]
  end

  it "can sort descending" do
    @scope = CDQ::Scope.new
    @scope.sort_by(:name, :desc).sort_descriptors.should == [
      NSSortDescriptor.sortDescriptorWithKey('name', ascending: false)
    ]
  end

  it "can chain sorts" do
    @scope = CDQ::Scope.new
    @scope.sort_by(:name).sort_by(:title).sort_descriptors.should == [
      NSSortDescriptor.sortDescriptorWithKey('name', ascending: true),
      NSSortDescriptor.sortDescriptorWithKey('title', ascending: true)
    ]
  end

  it "handles complex examples" do
    scope1 = CDQ::Scope.new
    scope2 = scope1.where(CDQ::Scope.new.where(:name).ne('bob', NSCaseInsensitivePredicateOption).or(:amount).gt(42).sort_by(:name))
    scope3 = scope1.where(CDQ::Scope.new.where(:enabled).eq(true).and(:'job.title').ne(nil).sort_by(:amount, :desc))

    scope4 = scope3.where(scope2)
    scope4.predicate.predicateFormat.should == '(enabled == 1 AND job.title != nil) AND (name !=[c] "bob" OR amount > 42)'
    scope4.sort_descriptors.should == [
      NSSortDescriptor.alloc.initWithKey('amount', ascending:false),
      NSSortDescriptor.alloc.initWithKey('name', ascending:true)
    ]
  end

  it "can make a new scope with a new limit" do:w
    @scope = CDQ::Scope.new
    new_scope = @scope.limit(1)

    new_scope.limit.should == 1
    new_scope.offset.should == nil
  end
  
end
