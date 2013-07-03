
module CDQ
  class Scope

    attr_reader :predicate, :limit, :offset

    def initialize(opts = {})
      @predicate = opts[:predicate] || NSPredicate.predicateWithValue(true)
      @limit = opts[:limit]
      @offset = opts[:offset]
    end

    # Combine this scope with others in an intersection ("and") relationship
    def and(scope)
      case scope
      when Scope
        new_limit = [limit, scope.limit].compact.last
        new_offset = [offset, scope.offset].compact.last
        other_predicate = scope.predicate
      when NSPredicate
        other_predicate = scope
        new_limit = limit
        new_offset = offset
      end
      new_predicate = NSCompoundPredicate.andPredicateWithSubpredicates([self.predicate, other_predicate])
      self.class.new(predicate: new_predicate, limit: new_limit, offset: new_offset)
    end
  end
end

