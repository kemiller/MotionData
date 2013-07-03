
describe "CDQ Partial Predicates" do

  before do 
    @scope = CDQ::Scope.new
    @ppred = CDQ::PartialPredicate.new(:count, @scope)
  end

  it "is composed of a key symbol and a scope" do
    @ppred.key.should == :count
    @ppred.scope.should.not == nil
  end

  it "creates an equality predicate" do
    scope = @ppred.eq(1)
    scope.predicate.should == NSCompoundPredicate.andPredicateWithSubpredicates(
      [NSPredicate.predicateWithValue(true), make_pred('count', NSEqualToPredicateOperatorType, 1)]
    )

    scope = @ppred.equal(1)
    scope.predicate.should == NSCompoundPredicate.andPredicateWithSubpredicates(
      [NSPredicate.predicateWithValue(true), make_pred('count', NSEqualToPredicateOperatorType, 1)]
    )
  end

  it "creates a less-than predicate" do
    scope = @ppred.lt(1)
    scope.predicate.should == NSCompoundPredicate.andPredicateWithSubpredicates(
      [NSPredicate.predicateWithValue(true), make_pred('count', NSLessThanPredicateOperatorType, 1)]
    )
  end

  it "preserves the previous scope" do
    scope = CDQ::Scope.new(predicate: NSPredicate.predicateWithValue(false))
    ppred = CDQ::PartialPredicate.new(:count, scope)
    ppred.eq(1).predicate.should == NSCompoundPredicate.andPredicateWithSubpredicates(
      [NSPredicate.predicateWithValue(false), make_pred('count', NSEqualToPredicateOperatorType, 1)]
    )
  end

  it "works with 'or' too" do
    ppred = CDQ::PartialPredicate.new(:count, @scope, :or)
    ppred.eq(1).predicate.should == NSCompoundPredicate.orPredicateWithSubpredicates(
      [NSPredicate.predicateWithValue(true), make_pred('count', NSEqualToPredicateOperatorType, 1)]
    )
  end
  def make_pred(key, type, value, options = 0)
    NSComparisonPredicate.predicateWithLeftExpression(
      NSExpression.expressionForKeyPath(key.to_s),
      rightExpression:NSExpression.expressionForConstantValue(value),
      modifier:NSDirectPredicateModifier,
      type:type,
      options:options)
  end
end
