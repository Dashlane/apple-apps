import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

public struct AccountTransferInfo: Hashable, Equatable, Sendable {

  @Loggable
  enum Error: Swift.Error {
    case invalidData
  }
  public let login: Login
  public let masterKey: MasterKey
  public let accountType: AccountType
  public let authTicket: AuthTicket?
  public let verificationMethod: VerificationMethod

  var ssoKey: String? {
    switch masterKey {
    case .masterPassword:
      return nil
    case .ssoKey(let data):
      return data.base64EncodedString()
    }
  }

  init(receivedData: DeviceToDeviceTransferData, apiClient: AppAPIClient) async throws {
    guard let masterKey = receivedData.key.masterKey else {
      throw AccountTransferInfo.Error.invalidData
    }
    let authTicket: AuthTicket? =
      if let token = receivedData.token {
        try await apiClient.authTicket(fromToken: token, login: receivedData.login)
      } else {
        nil
      }

    if authTicket == nil, receivedData.key.accountType != .masterPassword {
      throw AccountTransferInfo.Error.invalidData
    }

    self.init(
      login: Login(receivedData.login), masterKey: masterKey,
      accountType: receivedData.key.accountType, verificationMethod: .emailToken,
      authTicket: authTicket)
  }

  public init(
    login: Login,
    masterKey: MasterKey,
    accountType: AccountType,
    verificationMethod: VerificationMethod,
    authTicket: AuthTicket?
  ) {
    self.login = login
    self.masterKey = masterKey
    self.accountType = accountType
    self.verificationMethod = .emailToken
    self.authTicket = authTicket
  }
}
