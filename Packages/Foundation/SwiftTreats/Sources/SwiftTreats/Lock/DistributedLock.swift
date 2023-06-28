import Foundation
import Combine
public class DistributedLock: Locking {
    private static let noOwnerValue: String = ""

    public let url: URL
            private let maximumLockDuration: TimeInterval

    private let ownerId: String
    private let coordinator = NSFileCoordinator(filePresenter: nil)
    private var locked: Bool = false

    public init(id: String = UUID().uuidString, url: URL, maximumLockDuration: TimeInterval = 60 * 2) {
        self.ownerId = id
        self.url = url
        self.maximumLockDuration = maximumLockDuration

        coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: nil) { writeURL in
            if !FileManager.default.fileExists(atPath: writeURL.path) {
                try? self.writeOwner(Self.noOwnerValue, to: writeURL)
            }
        }
    }

    public func lock() throws {
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
            try takeOwnership(of: url)
        case ownerId:
            if !locked { 
                try takeOwnership(of: url)
            } else {
                throw LockError.alreadyLocked(isCurrentInstanceOwner: true)
            }

        default:
                        if let date = FileManager.default.modificationDate(of: url),
               abs(date.timeIntervalSinceNow) >= maximumLockDuration {
                try takeOwnership(of: url)
            } else {
                self.locked = false
                throw LockError.alreadyLocked(isCurrentInstanceOwner: false)
            }
        }
    }

    private func takeOwnership(of url: URL) throws {
        try writeOwner(ownerId, to: url)
        locked = true
    }

    private func writeOwner(_ owner: String, to url: URL) throws {
                try owner.write(to: url, atomically: false, encoding: .utf8)
    }

    public func unlock() {
        coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: nil) { writeURL in
            do {
                defer {
                    self.locked = false
                }
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
        var shouldRetry = false
        repeat {
            shouldRetry = false

            do {
                try await withTimeout(maximumLockDuration + 1) {
                                        var iterator = self.url.events([.all])
                        .compactMap { [weak self] _ -> Bool? in
                            guard let self = self else {
                                return nil
                            }

                            do {
                                try self.lock()
                                return true
                            } catch { 
                                return nil
                            }
                        }

                        .makeAsyncIterator()

                    _ = try await iterator.next() 
                }
            } catch is TimedOutError {
                                shouldRetry = true
            }
        } while shouldRetry
    }
}

fileprivate extension FileManager {
    func modificationDate(of url: URL) -> Date? {
        guard let attr = try? attributesOfItem(atPath: url.path) else {
            return nil
        }
        return attr[FileAttributeKey.modificationDate] as? Date
    }
}
