import Foundation
import SwiftTreats

actor ActivityReportsLocalStoreBatcher {

        private let saver: ActivityReportsLocalStoreSaver

        private let throttler = AsyncDelayingScheduler(policy: .throttle(latest: true), duration: 2.0)

        private var entries = [LogCategory: Set<Data>]()

        init(saver: ActivityReportsLocalStoreSaver) {
        self.saver = saver
    }

            public func fetchEntries(max: Int, of category: LogCategory) async throws -> [LogEntry] {
                await throttler.cancel()
                try self.storeLocallyMemoryEntries(entries)
        self.entries = [:]

        let storedEntries = saver.fetchEntries(max: max, of: category)

        return storedEntries
    }

                public func store(_ data: Data, category: LogCategory) async throws {
                entries[category, default: []].insert(data)

                await throttler {
            let entriesToSave = self.entries
            try self.storeLocallyMemoryEntries(entriesToSave)
            self.entries.filtering(entries: entriesToSave)
        }
    }

        private func storeLocallyMemoryEntries(_ entries: [LogCategory: Set<Data>]) throws {
        for categoryAndEntries in entries where !categoryAndEntries.value.isEmpty {
            let category = categoryAndEntries.key
                        let joinedData = Data(categoryAndEntries.value.joined(separator: "\n".utf8))
            try saver.store(joinedData, category: category)
        }
    }
}

private extension [LogCategory: Set<Data>] {
    mutating func filtering(entries: [LogCategory: Set<Data>]) {
        for categoryAndData in self {
            let filtered = (self[categoryAndData.key] ?? []).subtracting(entries[categoryAndData.key] ?? [])
            self[categoryAndData.key] = filtered
        }
    }

    mutating func filtering(entries: Set<Data>) {
        for categoryAndData in self {
            let filtered = (self[categoryAndData.key] ?? []).subtracting(entries)
            self[categoryAndData.key] = filtered
        }
    }
}
