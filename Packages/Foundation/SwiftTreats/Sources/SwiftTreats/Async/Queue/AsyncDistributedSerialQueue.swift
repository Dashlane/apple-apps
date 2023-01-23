import Foundation

public struct AsyncDistributedSerialQueue: AsyncQueue {
    let lock: DistributedLock
    
    public init(lock: DistributedLock) {
        self.lock = lock
    }
    
    public init(lockFile: URL, maximumLockDuration: TimeInterval = 60 * 2) {
        self.init(lock: DistributedLock(url: lockFile,  maximumLockDuration: maximumLockDuration))
    }
    
    public func callAsFunction<Output>(_ operation: @Sendable @escaping () async throws -> Output) async throws -> Output {
        try await lock.lockByWaitingOwnershipRelease()
        defer {
            lock.unlock()
        }
        let result = try await operation()
        return result
    }
}
