import Foundation
import Combine
import GRDB
import DashTypes

private let fetcherQueue = DispatchQueue(label: "com.dashlane.PersonalDataFetcher",
                                         qos: .utility,
                                         attributes: .concurrent)

class PersonalDataAutoFetcher<T: PersonalDataCodable> {
    typealias Values = Dictionary<Identifier, T>.Values
    
    let itemsPublisher = PassthroughSubject<Values, Never>()
    var items: Values { return cache.values }
    let stack: ApplicationDatabase
    let logger: Logger

    private var cache: [Identifier: T] = [:]
    private var subscription: AnyCancellable?
    
    convenience init(stack: ApplicationDBStack) {
        self.init(stack: stack,
                  logger: stack.logger,
                  databaseEventPublisher: stack.driver.eventPublisher)
    }
    
    init(stack: ApplicationDatabase,
         logger: Logger,
         databaseEventPublisher: PassthroughSubject<DatabaseEvent, Never>) {
        self.stack = stack
        self.logger = logger
        
        subscription = databaseEventPublisher
            .prepend(.invalidation)
            .receive(on: fetcherQueue)
            .sink { [weak self] event in
                do {
                    switch event {
                        case .invalidation:
                            try self?.fetchAll()
                        case let .incrementalChanges(changes):
                            try self?.update(for: changes)
                    }
                } catch {
                    logger.fatal("Fetcher for type \(T.contentType) failed", error: error)
                }
            }
    }
    
    
    private func fetchAll() throws {
        logger.debug("Fetching all items for type \(T.contentType)")
        let items = try stack.fetchAll(T.self)
        self.cache = Dictionary(items)
        itemsPublisher.send(self.items)
    }
    
        private func update(for changeSets: Set<DatabaseChange>) throws {
        guard changeSets.count < 100 else { 
            try fetchAll()
            return
        }
    
                let insertedOrUpdatedIds = changeSets
            .filter { change in
                switch change.kind {
                    case .insertedOrUpdated(contentType: T.contentType): 
                        return true
                    case .metadataUpdated: 
                        return cache.keys.contains(change.id)
                    default:
                        return false
                }
            }
            .map(\.id)
        
        if !insertedOrUpdatedIds.isEmpty {
            let newItems = try stack.fetchAll(with: insertedOrUpdatedIds, type: T.self)
            let newItemByIds = Dictionary(newItems)
            for id in insertedOrUpdatedIds {
                cache[id] = newItemByIds[id] 
            }
        }
     
                let removedIds = changeSets
            .filter { $0.kind == .deleted && cache[$0.id] != nil }
            .map(\.id)
        
        for id in removedIds {
            cache[id] = nil
        }
        
        guard !insertedOrUpdatedIds.isEmpty || !removedIds.isEmpty else {
            return
        }
        
        logger.debug("Updating items for type \(T.contentType) insertOrUpdatedIds: \(insertedOrUpdatedIds) removedIds: \(removedIds)")
        itemsPublisher.send(self.items)
    }
}


private extension Dictionary where Key == Identifier, Value: PersonalDataCodable {
    init(_ items: [Value]) {
        self.init(minimumCapacity: items.count)
        for item in items {
            self[item.metadata.id] = item
        }
    }
}
