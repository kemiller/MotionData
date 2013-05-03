module MotionData

  module CoreTypes
    class Boolean
    end

    class Integer16
    end

    class Integer32
    end

    class Transformable
    end

    class Float
    end

    class Time
    end
  end

  class ManagedObject < MotionDataManagedObjectBase
    include CoreTypes

    extend Predicate::Builder::Mixin
    include Predicate::Builder::Mixin

    class << self

      def inherited(klass)
        klass.entityDescription.propertiesByName.each do |name, attDesc|
          case attDesc
          when NSAttributeDescription
            if attDesc.attributeType == NSBooleanAttributeType
              klass.definePropertyPredicateAccessor(name)
            end
          when NSRelationshipDescription
            if attDesc.isToMany
              klass.defineRelationshipMethod(name)
            end
          end
        end
      end

      def new(properties = nil)
        newInContext(Context.current, properties)
      end

      def newInContext(context, properties = nil)
        entity = alloc.initWithEntity(entityDescription, insertIntoManagedObjectContext:context)
        properties.each { |k, v| entity.send("#{k}=", v) } if properties
        entity
      end

      # Core Data dynamically creates subclasses of model classes in order to
      # add the property accessors. These subclasses are named after the user’s
      # class, but contain underscores.
      #
      # E.g. if the user’s model would be called `Author`, the dynamic subclass
      # would be called `Author_Author_`.
      def dynamicSubclass?
        @dynamicSubclass = name.include?('_') if @dynamicSubclass.nil?
        @dynamicSubclass
      end

      # Returns the model class as defined by the user, even if called on a
      # class dynamically defined by Core Data.
      def modelClass
        @modelClass ||= begin
          if dynamicSubclass?
            # TODO this will probably break if the user namespaces the model class
            Object.const_get(name.split('_').first)
          else
            self
          end
        end
      end

      # Returns the entity description from the model class as defined by the
      # user, even if called on a class dynamically defined by Core Data.
      def entityDescription
          if dynamicSubclass?
            modelClass.entityDescription
          else
            MotionData.managedObjectModel.entitiesByName[name]
          end
      end

      # Finders

      def all
        Scope::Model.alloc.initWithTarget(self)
      end

      def where(conditions)
        all.where(conditions)
      end

      # TODO copy to subclasses of abstract models
      def scopes
        @scopes ||= {}
      end

      # Adds a named scope to the class and makes it available as a class
      # method named after the scope.
      def scope(name, scope)
        name = name.to_sym
        scopes[name] = scope
        defineNamedScopeMethod(name)
        scope
      end

      # Called from method that's dynamically added from
      # +[MotionDataManagedObjectBase defineNamedScopeMethod:]
      def scopeByName(name)
        scopes[name.to_sym]
      end
    end

    def destroy
      managedObjectContext.deleteObject(self)
    end

    # Called from method that's dynamically added from
    # +[MotionDataManagedObjectBase defineRelationshipMethod:]
    def relationshipByName(name)
      willAccessValueForKey(name)
      set = Scope::Relationship.extendRelationshipSetWithScope(primitiveValueForKey(name),
                                              relationshipName:name,
                                                         owner:self)
      didAccessValueForKey(name)
      set
    end

    def writeAttribute(key, value)
      key = key.to_s
      willChangeValueForKey(key)
      setPrimitiveValue(value, forKey:key)
      didChangeValueForKey(key)
    end

    # Called from method that's dynamically added from
    # +[MotionDataManagedObjectBase definePropertyPredicateAccessor:]
    def rubyBooleanValueForKey(name)
      case send(name)
      when 0
        false
      when 1
        true
      when nil
        nil
      else
        raise "Unsupported value for key `#{name}'"
      end
    end

    def inspect
      description
    end
  end

end
