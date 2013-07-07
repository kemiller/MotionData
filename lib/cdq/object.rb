
module CDQ

  class CDQObject

    def contexts
      @@context_manager ||= CDQContextManager.new(store_coordinator: store_coordinator)
    end

    def store_coordinator
      MotionData::StoreCoordinator.default
    end

    def reset!(opts = {})
      @@context_manager.reset!
      @@context_manager = nil
      MotionData.resetCoreDataStack(opts)
    end

    def setup(opts = {})
      MotionData.setupCoreDataStack(opts)
      contexts.new(NSPrivateQueueConcurrencyType)
      contexts.new(NSMainQueueConcurrencyType)
    end

    protected

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

