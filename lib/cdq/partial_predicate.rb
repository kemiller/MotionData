
module CDQ
  class PartialPredicate

    attr_reader :key, :scope

    def initialize(key, scope)
      @key = key
      @scope = scope
    end

  end
end

