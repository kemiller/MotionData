
module CDQ

  class CDQContextManager

    def initialize(opts = {})
      @store_coordinator = opts[:store_coordinator]
    end

    # Push a new context onto the stack for the current thread, making that context the
    # default. If a block is supplied, push for the duration of the block and then
    # return to the previous state.
    #
    def push(context, &block)
      if block_given?
        save_stack do
          push_to_stack(context)
          block.call
        end
      else
        push_to_stack(context)
      end
    end

    # Pop the top context off the stack.  If a block is supplied, pop for the
    # duration of the block and then return to the previous state.
    #
    def pop(&block)
      if block_given?
        save_stack do
          rval = pop_from_stack
          block.call
        end
      else
        pop_from_stack
      end
    end

    # The current context at the top of the stack.
    # 
    def current
      stack.last
    end

    # An array of all contexts, from bottom to top of the stack.
    #
    def all
      stack.dup
    end

    # Remove all contexts.
    #
    def reset!
      self.stack = []
    end

    # Create and push a new context with the specified concurrency type.  Its parent
    # will be set to the previous head context.  If a block is supplied, the new context
    # will exist for the duration of the block and then the previous state will be restored.
    #
    def new(concurrency_type, &block)
      context = NSManagedObjectContext.alloc.initWithConcurrencyType(concurrency_type)
      if current
        context.parentContext = current
      else
        context.persistentStoreCoordinator = @store_coordinator
      end
      push(context, &block)
    end

    # Save all contexts in the stack, starting with the current and working down.
    #
    def save
      stack.reverse.each do |context|
        context.save
      end
    end

    private

    def push_to_stack(value)
      lstack = stack
      lstack << value
      self.stack = lstack
      value
    end

    def pop_from_stack
      lstack = stack
      value = lstack.pop
      self.stack = lstack
      value
    end

    def save_stack(&block)
      begin
        saved_stack = all
        block.call
      ensure
        self.stack = saved_stack
      end
    end

    def stack
      Thread.current[:"cdq.context.stack.#{object_id}"] || []
    end

    def stack=(value)
      Thread.current[:"cdq.context.stack.#{object_id}"] = value
    end

  end

end
