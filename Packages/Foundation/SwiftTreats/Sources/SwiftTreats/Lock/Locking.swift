import Foundation

public protocol Locking {
        func lock() throws
        func unlock()
}


public enum LockError: Error, Equatable {
    case alreadyLocked(isCurrentInstanceOwner: Bool)
}
