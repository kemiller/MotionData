
module CDQ
  class PartialPredicate

    attr_reader :key, :scope

    def initialize(key, scope)
      @key = key
      @scope = scope
    end

    def eq(value)
      Scope.new(predicate: make_pred(key, NSEqualToPredicateOperatorType, value))
    end

    private

    def make_pred(key, type, value, options = 0)
      NSComparisonPredicate.predicateWithLeftExpression(
        NSExpression.expressionForKeyPath(key.to_s),
        rightExpression:NSExpression.expressionForConstantValue(value),
        modifier:NSDirectPredicateModifier,
        type:type,
        options:options)
    end
  end
end

