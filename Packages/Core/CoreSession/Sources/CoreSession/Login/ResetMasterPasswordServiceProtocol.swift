import Combine
import Foundation

public protocol ResetMasterPasswordServiceProtocol {
  var isActive: Bool { get }
  var needsReactivation: Bool { get }

  func activate(using masterPassword: String) throws
  func deactivate() throws
  func activationStatusPublisher() -> AnyPublisher<Bool, Never>

  func storedMasterPassword() throws -> String
  func update(masterPassword: String) throws
}

public class ResetMasterPasswordServiceMock: ResetMasterPasswordServiceProtocol {

  public init(isActive: Bool = false, needsReactivation: Bool = false) {
    self.isActive = isActive
    self.needsReactivation = needsReactivation
  }

  public var isActive: Bool = false

  public var needsReactivation: Bool = false

  public func activationStatusPublisher() -> AnyPublisher<Bool, Never> {
    return PassthroughSubject<Bool, Never>().eraseToAnyPublisher()
  }

  public func update(masterPassword: String) throws {

  }

  public func activate(using masterPassword: String) throws {
    self.isActive = true
  }

  public func deactivate() throws {
    self.isActive = false
  }

  public func storedMasterPassword() throws -> String {
    return "test"
  }
}
