
module CDQ

  class CDQObject; end
  class CDQQuery < CDQObject; end
  class CDQPartialPredicate < CDQObject; end
  class CDQTargetedQuery < CDQQuery; end

  def cdq(obj = nil)
    obj ||= self
    case obj
    when Class
      if obj.isSubclassOfClass(NSManagedObject)
        entity_description = MotionData.managedObjectModel.entitiesByName[obj.name]
        if entity_description.nil?
          raise "Cannot find an entity named #{obj.name}"
        end
        CDQTargetedQuery.new(entity_description, obj)
      else
        raise "CDQ doesn't know what to do with #{obj}"
      end
    when String
      entity_description = MotionData.managedObjectModel.entitiesByName[obj]
      if entity_description.nil?
        raise "Cannot find an entity named #{obj}"
      end
      CDQTargetedQuery.new(entity_description, NSManagedObject)
    when Symbol
      CDQPartialPredicate.new(obj, CDQQuery.new)
    when CDQObject
      obj
    else
      raise "CDQ doesn't know what to do with #{obj}"
    end
  end

end
