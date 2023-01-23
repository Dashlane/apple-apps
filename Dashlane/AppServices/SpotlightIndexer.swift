import Foundation
import Combine
import CoreSpotlight
import DashTypes

enum SpotlightDomainIdentifier: String {
    case vaultItem
}

struct SpotlightIndexer {
    let logger: Logger
    let searchableIndex: CSSearchableIndex = CSSearchableIndex.default()

    init(logger: Logger) {
        self.logger = logger
    }

    func deleteAll(completion: (() -> Void)? = nil) {
        searchableIndex.deleteAllSearchableItems { error in
            if let error = error {
                self.logger.error("Spotlight deleting error", error: error)
            } else {
                self.logger.debug("Spotlight deleting success")
            }
            completion?()
        }
    }

    func deleteIndexedItems(for domain: SpotlightDomainIdentifier, completion: (() -> Void)? = nil) {
        searchableIndex.deleteSearchableItems(withDomainIdentifiers: [domain.rawValue]) { error in
            if let error = error {
                self.logger.error("Spotlight deleting for domain \(domain.rawValue) failed", error: error)
            } else {
                self.logger.debug("Spotlight deleting success")
            }
            completion?()
        }
    }

    func deleteIndexedItems(withIdentifiers identifiers: [String], completion: (() -> Void)? = nil) {
        searchableIndex.deleteSearchableItems(withIdentifiers: identifiers) { error in
            if let error = error {
                self.logger.error("Spotlight deleting failed", error: error)
            } else {
                self.logger.debug("Spotlight deleting success")
            }
            completion?()
        }
    }

    func index(_ items: [CSSearchableItem], completion: (() -> Void)? = nil) {
        guard CSSearchableIndex.isIndexingAvailable() else {
            self.logger.debug("Spotlight not available")
            return
        }
        searchableIndex.indexSearchableItems(items) {  error in
            if let error = error {
                self.logger.error("Spotlight Indexing vault items failed", error: error)
            } else {
                self.logger.debug("Spotlight Indexing vault items success")
            }
            completion?()
        }
    }
}
