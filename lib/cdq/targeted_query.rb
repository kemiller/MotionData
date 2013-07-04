
module CDQ

  class Scope; end

  class TargetedQuery < Scope

    include Enumerable

    def initialize(target, opts = {})
      super(opts)
      @target = target
    end

    def count
      error = Pointer.new(:object)
      result = MotionData::Context.current.countForFetchRequest(fetch_request, error:error)
      if error[0]
        raise "Error while fetching: #{error[0].debugDescription}"
      end
      result || 0
    end

    def array
      error = Pointer.new(:object)
      result = MotionData::Context.current.executeFetchRequest(fetch_request, error:error)
      if error[0]
        raise "Error while fetching: #{error[0].debugDescription}"
      end
      result || []
    end

    def first
      limit(1).array.first
    end

    def [](index)
      offset(index).first
    end

    def each(&block)
      array.each(&block)
    end

    def fetch_request
      super.tap do |req|
        req.entity = @target
      end
    end

    private

    def new(opts = {})
      self.class.new(@target, locals.merge(opts))
    end
  end
end
