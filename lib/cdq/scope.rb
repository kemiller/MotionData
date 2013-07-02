
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
      new_limit = [limit, *scopes.map(&:limit)].compact.last
      new_offset = [offset, *scopes.map(&:offset)].compact.last
      self.class.new(predicate: NSCompoundPredicate.andPredicateWithSubpredicates([self.predicate, *scopes.map(&:predicate)]),
                     limit: new_limit, offset: new_offset)
    end
  end
end

