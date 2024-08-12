import Foundation

public struct Lock: Locking {
  private let systemLock = NSLock()

  public init() {

  }

  public func lock() throws {
    guard systemLock.try() else {
      throw LockError.alreadyLocked(isCurrentInstanceOwner: true)
    }
  }

  public func unlock() {
    systemLock.unlock()
  }
}
