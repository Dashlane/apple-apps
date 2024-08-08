import DashTypes
import Foundation

public protocol SessionCleanerProtocol {
  func removeLocalData(for login: Login)
}

public struct SessionCleanerMock: SessionCleanerProtocol {
  public func removeLocalData(for login: Login) {}
}

extension SessionCleanerProtocol where Self == SessionCleanerMock {
  public static var mock: SessionCleanerMock {
    return SessionCleanerMock()
  }
}
