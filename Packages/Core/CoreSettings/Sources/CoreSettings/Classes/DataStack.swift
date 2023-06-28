import CoreData

extension NSManagedObjectContext {
    func recursiveSave() throws {
        guard self.hasChanges else {
            return
        }

        try self.save()

        if let parent = self.parent {
            var result: Result<Void, Error> = .failure(URLError(.unknown))
            switch parent.concurrencyType {
                case .mainQueueConcurrencyType:
                    DispatchQueue.main.sync {
                        parent.performAndWait {
                            result = .init(catching: parent.recursiveSave)
                        }
                    }
                default:
                    parent.performAndWait {
                        result = .init(catching: parent.recursiveSave)
                    }
            }

            try result.get()
        }
    }
}

final class DataStack {

    private let persistentStore: NSPersistentStoreCoordinator

    let main: NSManagedObjectContext

    var concurrent: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = main
        return context
    }

    var currentThreadContext: NSManagedObjectContext {
        return Thread.isMainThread ? main : concurrent
    }

        init?(modelURL: URL, storeURL: URL) {
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            return nil
        }
        persistentStore = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try self.persistentStore.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
                ])
        } catch {
            fatalError("Unable to create store: \(error.localizedDescription)")
        }
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStore
        main = context
    }

}
