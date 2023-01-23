import Foundation

public struct DistributedLock: Locking {
    private static let noOwnerValue: String = ""
    
    public let url: URL
            private let maximumLockDuration: TimeInterval
    
    private let ownerId = UUID().uuidString
    private let coordinator = NSFileCoordinator(filePresenter: nil)


    public init(url: URL, maximumLockDuration: TimeInterval = 60 * 2) {
        self.url = url
        self.maximumLockDuration = maximumLockDuration
        
        coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: nil) { writeURL in
            if !FileManager.default.fileExists(atPath: writeURL.path) {
                try? self.writeOwner(Self.noOwnerValue, to: writeURL)
            }
        }
    }

    public func lock() throws  {
        var result: Result<Void, Error> = .failure(URLError(.unknown))

        coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: nil) { writeURL in
            result = Result {
                try acquire(writeURL)
            }
        }
        
        return try result.get()
    }
    
    private func acquire(_ url: URL) throws {
        let currentOwnerId = try? String(contentsOf: url)
        switch currentOwnerId {
            case nil, Self.noOwnerValue:
                try writeOwner(ownerId, to: url)
            case ownerId:
                throw LockError.alreadyLocked(isCurrentInstanceOwner: true)
            default:
                                if let date = FileManager.default.modificationDate(of: url),
                   abs(date.timeIntervalSinceNow) > maximumLockDuration {
                    try writeOwner(ownerId, to: url)
                } else {
                    throw LockError.alreadyLocked(isCurrentInstanceOwner: false)
                }
        }
    }
    
    private func writeOwner(_ owner: String,  to url: URL) throws {
                try owner.write(to: url, atomically: false, encoding: .utf8)
    }
    
    public func unlock() {
        coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: nil) { writeURL in
            do {
                let currentOwnerId = try String(contentsOf: writeURL)
                guard currentOwnerId == ownerId else {
                    return
                }
                try writeOwner(Self.noOwnerValue, to: writeURL)
            } catch {
                
            }
        }
    }
}

extension DistributedLock {
        public func lockByWaitingOwnershipRelease() async throws {
        var iterator = url.events([.all])
            .compactMap { event -> Bool? in
                do {
                    try lock()
                    return true
                } catch {
                    return nil
                }
            }
            .makeAsyncIterator()
        
        let _ = try await iterator.next()
    }
}

fileprivate extension FileManager {
    func modificationDate(of url: URL) -> Date? {
        guard let attr = try? attributesOfItem(atPath: url.path) else{
            return nil
        }
        return attr[FileAttributeKey.modificationDate] as? Date
    }
}
