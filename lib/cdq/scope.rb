
module CDQ
  class Scope

    attr_reader :predicate, :limit, :offset

    def initialize(opts = {})
      @predicate = opts[:predicate] || NSPredicate.predicateWithValue(true)
      @limit = opts[:limit]
      @offset = opts[:offset]
    end

    # Combine this scope with others in an intersection ("and") relationship
    def and(*scopes)
      self.class.new(predicate: NSCompoundPredicate.andPredicateWithSubpredicates([self.predicate, *scopes.map(&:predicate)]))
    end
  end
end

