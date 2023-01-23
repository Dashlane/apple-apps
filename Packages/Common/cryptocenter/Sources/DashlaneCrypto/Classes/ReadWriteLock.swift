import Foundation

public final class ReadWriteLock {
    private var lock: UnsafeMutablePointer<pthread_rwlock_t>

    public init() {
        lock = UnsafeMutablePointer.allocate(capacity: 1)
        let status = pthread_rwlock_init(lock, nil)
        assert(status == 0)
    }

    deinit {
        let status = pthread_rwlock_destroy(lock)
        assert(status == 0)
        lock.deallocate()
    }

    public func withReadLock<T>( _ body: () throws -> T) rethrows -> T {
        pthread_rwlock_rdlock(lock)

        defer {
            pthread_rwlock_unlock(lock)
        }

        return try body()
    }

    public func withWriteLock<T>( _ body: () throws -> T) rethrows -> T {
        pthread_rwlock_wrlock(lock)

        defer {
            pthread_rwlock_unlock(lock)
        }

        return try body()
    }
}
