
module CDQ

  class CDQQuery; end

  class CDQTargetedQuery < CDQQuery

    include Enumerable

    def initialize(target, opts = {})
      super(opts)
      @target = target
    end

    def count
      with_error_object(0) do |error|
        MotionData::Context.current.countForFetchRequest(fetch_request, error:error)
      end
    end

    def array
      with_error_object([]) do |error|
        MotionData::Context.current.executeFetchRequest(fetch_request, error:error)
      end
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

    def with_error_object(default, &block)
      error = Pointer.new(:object)
      result = block.call(error)
      if error[0]
        raise "Error while fetching: #{error[0].debugDescription}"
      end
      result || default
    end

  end
end
