import Foundation

public typealias MasterPassword = String

public protocol ResetContainerKeychainManager: Sendable {
  func checkStatus() throws -> ResetContainerStatus
  func get() throws -> ResetContainer
  @discardableResult
  func store(_ masterPassword: MasterPassword, accessMode: KeychainAccessMode) throws
    -> ResetContainer
  func remove() throws
}

public enum ResetContainerStatus: Equatable, Sendable {
  case available
  case notAvailable

  init(keychainItemStatus: KeychainItemStatus) {
    switch keychainItemStatus {
    case .found:
      self = .available
    case .notFound:
      self = .notAvailable
    }
  }
}

public struct ResetContainer {
  public let masterPassword: String

  public init(masterPassword: String) {
    self.masterPassword = masterPassword
  }
}
