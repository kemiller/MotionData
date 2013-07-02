
module CDQ
  class Scope

    attr_reader :predicate

    def initialize
      @predicate = NSPredicate.predicateWithValue(true)
    end
  end
end

