import DashTypes
import Foundation

public struct LoadSessionInformation {
  public let login: Login
  public let masterKey: MasterKey

  public init(
    login: Login,
    masterKey: MasterKey
  ) {
    self.login = login
    self.masterKey = masterKey
  }
}
