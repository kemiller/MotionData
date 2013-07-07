
module CDQ

  class CDQObject

    def context
      @context_manager ||= CDQContextManager.new(store_coordinator: MotionData::StoreCoordinator.default)
    end

  end

end

