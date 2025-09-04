import CoreTypes
import Foundation

public protocol SessionCleanerProtocol: Sendable {
  func removeLocalData(for login: Login)
  func cleanAutoLoginData(for login: Login)
}

public struct SessionCleanerMock: SessionCleanerProtocol {
  public func removeLocalData(for login: Login) {}
  public func cleanAutoLoginData(for login: Login) {}
}

extension SessionCleanerProtocol where Self == SessionCleanerMock {
  public static var mock: SessionCleanerMock {
    return SessionCleanerMock()
  }
}
