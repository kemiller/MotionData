
module CDQ
  class Scope

    EMPTY = Object.new

    attr_reader :predicate

    def initialize(opts = {})
      @predicate = opts[:predicate] || NSPredicate.predicateWithValue(true)
      @limit = opts[:limit]
      @offset = opts[:offset]
    end

    def limit(value = EMPTY)
      if value == EMPTY
        @limit
      else
        new(limit: value)
      end
    end

    def offset(value = EMPTY)
      if value == EMPTY
        @offset
      else
        new(offset: value)
      end
    end

    # Combine this scope with others in an intersection ("and") relationship
    def and(scope)
      merge_scope(scope) do |left, right|
        NSCompoundPredicate.andPredicateWithSubpredicates([left, right])
      end
    end
    alias :where, :and

    def or(scope)
      merge_scope(scope) do |left, right|
        NSCompoundPredicate.orPredicateWithSubpredicates([left, right])
      end
    end

    def new(opts = {})
      self.class.new({predicate: predicate, limit: limit, offset: offset}.merge(opts))
    end

    private

    def merge_scope(scope, &block)
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
      new_predicate = block.call(predicate, other_predicate)
      new(predicate: new_predicate, limit: new_limit, offset: new_offset)
    end

  end
end

