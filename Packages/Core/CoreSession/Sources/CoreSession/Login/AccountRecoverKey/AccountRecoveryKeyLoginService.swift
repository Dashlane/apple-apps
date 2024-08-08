import DashTypes
import DashlaneAPI
import Foundation

public struct AccountRecoveryKeyLoginService {

  enum AccountRecoveryError: Error {
    case cannotConvertFromBase64
  }

  let login: Login
  let appAPIClient: AppAPIClient
  let cryptoEngineProvider: CryptoEngineProvider

  public init(login: Login, appAPIClient: AppAPIClient, cryptoEngineProvider: CryptoEngineProvider)
  {
    self.login = login
    self.appAPIClient = appAPIClient
    self.cryptoEngineProvider = cryptoEngineProvider
  }

  public func masterKey(using recoveryKey: AccountRecoveryKey, authTicket: AuthTicket) async throws
    -> MasterKey
  {
    let encryptedVaultKey = try await appAPIClient.accountrecovery.getEncryptedVaultKey(
      login: login.email, authTicket: authTicket.value
    ).encryptedVaultKey
    guard let encryptedVaultKeyData = Data(base64Encoded: encryptedVaultKey) else {
      throw AccountRecoveryError.cannotConvertFromBase64
    }

    let cryptoEngine = try cryptoEngineProvider.cryptoEngine(
      forEncryptedVaultKey: encryptedVaultKeyData, recoveryKey: recoveryKey)

    let decryptedData = try cryptoEngine.decrypt(encryptedVaultKeyData)
    let decryptedMasterKey = String(decoding: decryptedData, as: UTF8.self)
    return .masterPassword(decryptedMasterKey)
  }
}

extension AccountRecoveryKeyLoginService {
  public static var mock: AccountRecoveryKeyLoginService {
    AccountRecoveryKeyLoginService(
      login: Login("_"), appAPIClient: .fake, cryptoEngineProvider: FakeCryptoEngineProvider())
  }
}
