module MotionData

  extend CDQ

  def self.setupCoreDataStack(options = {})
    path = databasePath(options[:databaseName])
    StoreCoordinator.default = StoreCoordinator.onDiskStore(managedObjectModel(options[:modelName]), path)
    cdq.contexts.new(NSPrivateQueueConcurrencyType)
    cdq.contexts.new(NSMainQueueConcurrencyType)
  end

  def self.resetCoreDataStack(options = {})
    path = databasePath(options[:databaseName])
    cdq.reset!
    NSFileManager.defaultManager.removeItemAtPath(path, error: nil)
  end

  def self.databasePath(name = nil)
    name ||= NSBundle.mainBundle.objectForInfoDictionaryKey("CFBundleDisplayName")
    dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).last
    path = File.join(dir, name + '.sqlite')
  end

  def self.managedObjectModel(name = nil)
    @managedObjectModel = nil if name
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
    @managedObjectModel
  end

end
