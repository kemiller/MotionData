
module CDQ
  class PartialPredicate

    attr_reader :key, :scope, :operation

    OPERATORS = {
      :eq => [NSEqualToPredicateOperatorType, :equal],
      :ne => [NSNotEqualToPredicateOperatorType, :not_equal],
      :lt => [NSLessThanPredicateOperatorType, :less_than],
      :le => [NSLessThanOrEqualToPredicateOperatorType, :less_than_or_equal],
      :gt => [NSGreaterThanPredicateOperatorType, :greater_than],
      :ge => [NSGreaterThanOrEqualToPredicateOperatorType, :greater_than_or_equal],
      :include => [NSContainsPredicateOperatorType],
      :in => [NSInPredicateOperatorType],
      :begins_with => [NSBeginsWithPredicateOperatorType],
      :ends_with => [NSEndsWithPredicateOperatorType]
    }
      
    def initialize(key, scope, operation = :and)
      @key = key
      @scope = scope
      @operation = operation
    end

    OPERATORS.each do |op, (type, synonym)|
      define_method(op) do |value| 
        make_scope(type, value)
      end
      alias synonym, op if synonym
    end

    def between(min, max);   make_scope(NSBetweenPredicateOperatorType, [min, max]); end
      
    private

    def make_pred(key, type, value, options = 0)
      NSComparisonPredicate.predicateWithLeftExpression(
        NSExpression.expressionForKeyPath(key.to_s),
        rightExpression:NSExpression.expressionForConstantValue(value),
        modifier:NSDirectPredicateModifier,
        type:type,
        options:options)
    end

    def make_scope(type, value)
      scope.send(operation, make_pred(key, type, value))
    end

  end
end

