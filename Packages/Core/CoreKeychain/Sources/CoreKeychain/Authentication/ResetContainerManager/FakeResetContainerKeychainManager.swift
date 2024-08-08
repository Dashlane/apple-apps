import Foundation

public final class FakeResetContainerKeychainManager: ResetContainerKeychainManager {
  private var masterPassword = "test"

  public func checkStatus() throws -> ResetContainerStatus {
    return .available
  }

  public func get() throws -> ResetContainer {
    return ResetContainer(masterPassword: masterPassword)
  }

  public func store(_ masterPassword: MasterPassword, accessMode: KeychainAccessMode) throws
    -> ResetContainer
  {
    self.masterPassword = masterPassword
    return try get()
  }

  public func remove() throws {
  }
}
