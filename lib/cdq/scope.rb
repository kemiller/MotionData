
module CDQ
  class Scope

    EMPTY = Object.new

    attr_reader :predicate, :sort_descriptors

    def initialize(opts = {})
      @predicate = opts[:predicate]
      @limit = opts[:limit]
      @offset = opts[:offset]
      @sort_descriptors = opts[:sort_descriptors] || []
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
      merge_scope(scope, :and) do |left, right|
        NSCompoundPredicate.andPredicateWithSubpredicates([left, right])
      end
    end
    alias_method :where, :and

    # Combine this scope with others in a union ("or") relationship
    def or(scope)
      merge_scope(scope, :or) do |left, right|
        NSCompoundPredicate.orPredicateWithSubpredicates([left, right])
      end
    end

    # Create a new scope with the same values as this one, optionally overriding
    # any of them in the options
    def new(opts = {})
      locals = {
        sort_descriptors: sort_descriptors,
        predicate: predicate,
        limit: limit,
        offset: offset
      }
      self.class.new(locals.merge(opts))
    end

    def sort_by(key, dir = :ascending)
      if dir.to_s[0,4].downcase == 'desc'
        ascending = false
      else 
        ascending = true
      end

      new(sort_descriptors: @sort_descriptors + [NSSortDescriptor.sortDescriptorWithKey(key, ascending: ascending)])
    end

    private

    def merge_scope(scope, operation, &block)
      case scope
      when Symbol
        return PartialPredicate.new(scope, self, operation)
      when Scope
        new_limit = [limit, scope.limit].compact.last
        new_offset = [offset, scope.offset].compact.last
        new_sort_descriptors = sort_descriptors + scope.sort_descriptors
        other_predicate = scope.predicate
      when NSPredicate
        other_predicate = scope
        new_limit = limit
        new_offset = offset
        new_sort_descriptors = sort_descriptors
      end
      if predicate
        new_predicate = block.call(predicate, other_predicate)
      else
        new_predicate = other_predicate
      end
      new(predicate: new_predicate, limit: new_limit, offset: new_offset, sort_descriptors: new_sort_descriptors)
    end

  end
end

