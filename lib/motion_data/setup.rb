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

=begin

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FunkyMonkey.sqlite"];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 

         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.


         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}

         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    

    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
=end

end
