
module CDQ
  class Scope

    attr_reader :predicate, :limit, :offset

    def initialize(opts = {})
      @predicate = NSPredicate.predicateWithValue(true)
      @limit = opts[:limit]
      @offset = opts[:offset]
    end
  end
end

