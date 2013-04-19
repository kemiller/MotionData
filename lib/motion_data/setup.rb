module MotionData

  def self.setupCoreDataStack(name)
    path = databasePath(name)
    Context.root = Context.main = nil
    StoreCoordinator.default = StoreCoordinator.onDiskStore(managedObjectModel(name), path)
  end

  def self.resetCoreDataStack(name)
    path = databasePath(name)
    NSFileManager.defaultManager.removeItemAtPath(path, error: nil)
  end

  def self.databasePath(name)
    dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).last
    path = File.join(dir, name + '.sqlite')
  end

  def self.managedObjectModel(name = nil)
    @managedObjectModel ||=
      begin
        name ||= NSBundle.mainBundle.objectForInfoDictionaryKey("CFBundleDisplayName")
        modelURL = NSBundle.mainBundle.URLForResource(name, withExtension: "momd");
        NSManagedObjectModel.alloc.initWithContentsOfURL(modelURL).mutableCopy.tap do |model|
          model.entitiesByName.each do |name, entityDesc|
            entityDesc.managedObjectClassName = name
          end
        end
      end
  end

  def self.saveAll
    MotionData::Context.current.saveChangesInAllContexts
  end

end
