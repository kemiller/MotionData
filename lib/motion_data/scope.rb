module MotionData
  class Scope
    include Enumerable

    attr_reader :target, :predicate, :sortDescriptors, :fetchLimit, :abstractPredicate

    def self.new
      alloc.initWithTarget(nil)
    end

    def initWithTarget(target)
      initWithTarget(target, predicate:nil, sortDescriptors:nil)
    end

    def initWithTarget(target, predicate:predicate, sortDescriptors:sortDescriptors)
      if init
        @target, @predicate = target, predicate
        @sortDescriptors    = sortDescriptors ? sortDescriptors.dup : []
      end
      self
    end

    def initWithTarget(target, abstractPredicate: block)
      @abstractPredicate = block
      initWithTarget(target)
      self
    end

    # Add finder conditions as a hash of requirements, a Scope, a NSPredicate,
    # or a predicate format string with an optional list of arguments.
    #
    # The conditions are added using `AND`.
    def where(conditions, *formatArguments)
      sortDescriptors = @sortDescriptors

      case conditions
      when Hash
        predicate = NSCompoundPredicate.andPredicateWithSubpredicates(conditions.map do |keyPath, value|
          Predicate::Builder.new(keyPath) == value
        end)
      when Scope
        sortDescriptors = sortDescriptorsByAddingSortDescriptors(*conditions.sortDescriptors)
        predicate = conditions.predicate
      when NSPredicate
        predicate = conditions
      when String
        predicate = NSPredicate.predicateWithFormat(conditions, argumentArray:formatArguments)
      else
        raise ArgumentError, "unsupported where conditions class `#{conditions.class}'"
      end

      predicate = @predicate.and(predicate) if @predicate
      scopeWithPredicate(predicate, sortDescriptors:sortDescriptors)
    end

    # Sort ascending by a key-path, or a NSSortDescriptor.
    def sortBy(keyPathOrSortDescriptor)
      if keyPathOrSortDescriptor.is_a?(NSSortDescriptor)
        scopeByAddingSortDescriptor(keyPathOrSortDescriptor)
      else
        sortBy(keyPathOrSortDescriptor, ascending:true)
      end
    end

    # Sort by a key-path.
    def sortBy(keyPath, ascending:ascending)
      scopeByAddingSortDescriptor(NSSortDescriptor.alloc.initWithKey(keyPath.to_s, ascending:ascending))
    end

    def limit(fetchLimit)
      @fetchLimit = fetchLimit
      self
    end

    # Iterates over the array representation of the scope.
    def each(&block)
      array.each(&block)
    end

    # Factory methods that should be implemented by the subclass.

    def array
      raise "Not implemented"
    end

    # TODO RM bug? aliased methods in subclasses don't call overriden version of aliased method.
    #alias_method :to_a, :array

    def to_a
      array
    end

    def first
      limit(1).array.first
    end

    def set
      raise "Not implemented."
    end

    def reify(args)
      if abstractPredicate
        where(abstractPredicate.call(*args))
      else
        self
      end
    end

    private

    def scopeWithPredicate(predicate, sortDescriptors:sortDescriptors)
      self.class.alloc.initWithTarget(@target, predicate:predicate, sortDescriptors:sortDescriptors)
    end

    def sortDescriptorsByAddingSortDescriptors(*sortDescriptors)
      descriptors = @sortDescriptors.dup
      descriptors.concat(sortDescriptors)
      descriptors
    end

    def scopeByAddingSortDescriptor(sortDescriptor)
      descriptors = sortDescriptorsByAddingSortDescriptors(sortDescriptor)
      scopeWithPredicate(@predicate, sortDescriptors:descriptors)
    end

  end

  class Scope
    class Set < Scope
      def set
        setByApplyingConditionsToSet(@target)
      end

      def array
        set = self.set
        set.is_a?(NSOrderedSet) ? set.array : set.allObjects
      end

      private

      # Applies the finder and sort conditions and returns the result as a set.
      def setByApplyingConditionsToSet(set)
        if @predicate
          if set.is_a?(NSOrderedSet)
            # TODO not the most efficient way of doing this when there are also sort descriptors
            filtered = set.array.filteredArrayUsingPredicate(@predicate)
            set = NSOrderedSet.orderedSetWithArray(filtered)
          else
            set = set.filteredSetUsingPredicate(@predicate)
          end
        end

        unless @sortDescriptors.empty?
          set = set.set if set.is_a?(NSOrderedSet)
          sorted = set.sortedArrayUsingDescriptors(@sortDescriptors)
          set = NSOrderedSet.orderedSetWithArray(sorted)
        end

        set
      end
    end
  end

  class Scope
    class Relationship < Scope::Set
      # A Core Data relationship set is extended with this module to provide
      # scoping by forwarding messages to a Scope::Relationship instance which
      # wraps the set.
      module SetExt
        attr_accessor :__scope__

        def set
          self
        end

        def respond_to?(method)
          @__scope__.respond_to?(method) || super
        end

        def method_missing(method, *args, &block)
          if respond_to?(method)
            @__scope__.send(method, *args, &block)
          else
            super
          end
        end
      end

      def self.extendRelationshipSetWithScope(set, relationshipName:relationshipName, owner:owner)
        set.extend SetExt
        set.__scope__ = Relationship.alloc.initWithTarget(set,
                                         relationshipName:relationshipName,
                                                    owner:owner)
        set
      end

      attr_accessor :relationshipName, :owner

      def initWithTarget(target, relationshipName:relationshipName, owner:owner)
        if initWithTarget(target)
          @relationshipName, @owner = relationshipName, owner
        end
        self
      end

      def new(properties = nil)
        entity = targetClass.newInContext(@owner.managedObjectContext, properties)
        # Uses the Core Data dynamically generated method to add objects to the relationship.
        #
        # E.g. if the relationship is called 'articles', then this will call: addArticles()
        #
        # TODO we currently use the one that takes a set instead of just one object, this is
        #      so we don't yet have to do any singularization
        camelized = @relationshipName.to_s.dup
        camelized[0] = camelized[0,1].upcase
        @owner.send("add#{camelized}", NSSet.setWithObject(entity))
        entity
      end

      # Returns a NSFetchRequest with the current scope.
      def fetchRequest
        # Start with a predicate which selects those entities that belong to the owner.
        predicate = Predicate::Builder.new(inverseRelationshipName) == @owner
        # Then apply the scope's predicate.
        predicate = predicate.and(@predicate) if @predicate

        request = NSFetchRequest.new
        request.entity = targetClass.entityDescription
        request.predicate = predicate
        request.fetchLimit = fetchLimit if fetchLimit
        request.sortDescriptors = @sortDescriptors unless @sortDescriptors.empty?
        request
      end

      def respond_to?(method)
        !targetClass.scopeByName(method).nil? || super
      end

      def method_missing(method, *args, &block)
        if scope = targetClass.scopeByName(method)
          where(scope)
        else
          super
        end
      end

      private

      def relationshipDescription
        @owner.class.entityDescription.relationshipsByName[@relationshipName]
      end

      def targetEntityDescription
        relationshipDescription.destinationEntity
      end

      def targetClass
        Kernel.const_get(targetEntityDescription.managedObjectClassName)
      end

      def inverseRelationshipName
        relationshipDescription.inverseRelationship.name
      end

      def scopeWithPredicate(predicate, sortDescriptors:sortDescriptors)
        scope = super
        scope.relationshipName = @relationshipName
        scope.owner = @owner
        scope
      end
    end
  end

  class Scope
    class Model < Scope
      def set
        @sortDescriptors.empty? ? NSSet.setWithArray(array) : NSOrderedSet.orderedSetWithArray(array)
      end

      def array
        error = Pointer.new(:object)
        result = Context.current.executeFetchRequest(fetchRequest, error:error)
        if error[0]
          raise "Error while fetching: #{error[0].debugDescription}"
        end
        result || []
      end

      def fetchRequest
        request = NSFetchRequest.new
        request.entity = @target.entityDescription
        request.predicate = @predicate
        request.sortDescriptors = @sortDescriptors unless @sortDescriptors.empty?
        request.fetchLimit = fetchLimit if fetchLimit
        request
      end

      def method_missing(method, *args, &block)
        if scope = @target.scopes[method]
          where(scope)
        else
          super
        end
      end
    end
  end
end
