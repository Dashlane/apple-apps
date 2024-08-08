import DashTypes
import DashlaneAPI
import Foundation

public typealias PendingTransfer = UserDeviceAPIClient.SecretTransfer.GetKeyExchangeTransferInfo
  .Response.Transfer

public class SenderSecurityChallengeService {

  enum Error: Swift.Error {
    case publicKeyHashNotMatching
  }

  let session: Session
  let apiClient: UserDeviceAPIClient
  let cryptoProvider: DeviceTransferCryptoKeysProvider

  public init(
    session: Session, apiClient: UserDeviceAPIClient,
    cryptoProvider: DeviceTransferCryptoKeysProvider
  ) {
    self.session = session
    self.apiClient = apiClient
    self.cryptoProvider = cryptoProvider
  }

  public func pendingTransfer() async throws -> PendingTransfer? {
    try await apiClient.secretTransfer.getKeyExchangeTransferInfo().transfer
  }

  public func transferKeys(for transfer: PendingTransfer) async throws -> SecurityChallengeKeys {
    let receiverPublicKey = try await apiClient.secretTransfer.startSenderKeyExchange(
      senderPublicKey: cryptoProvider.publicKeyString, transferId: transfer.transferId
    ).receiverPublicKey
    guard
      try cryptoProvider.compare(receiverPublicKey, hashedKey: transfer.receiver.hashedPublicKey)
    else {
      throw Error.publicKeyHashNotMatching
    }
    return try cryptoProvider.securityChallengeKeys(
      using: receiverPublicKey, login: session.login.email, transferId: transfer.transferId,
      origin: .sender)
  }

  public func startUniversalTransfer(
    with transferKeys: SecurityChallengeKeys, secretBox: DeviceTransferSecretBox
  ) async throws {
    let token = try await apiClient.authentication.token()
    let transferData = DeviceToDeviceTransferData(
      key: session.authenticationMethod.sessionKey.transferKey(
        accountType: session.configuration.info.accountType), token: token,
      login: session.login.email, version: 1)
    try await transferUniversalData(transferData, transferKeys: transferKeys, secretBox: secretBox)
  }

  private func transferUniversalData<T: Encodable>(
    _ transferData: T, transferKeys: SecurityChallengeKeys, secretBox: DeviceTransferSecretBox
  ) async throws {
    let (encryptedData, nonce) = try secretBox.seal(transferData, nonce: nil)
    try await apiClient.secretTransfer.completeTransfer(
      transfer: .init(
        transferType: .universal, transferId: transferKeys.transferId, encryptedData: encryptedData,
        nonce: nonce.base64EncodedString()))
  }
}

extension SenderSecurityChallengeService {
  public static var mock: SenderSecurityChallengeService {
    SenderSecurityChallengeService(
      session: .mock, apiClient: .fake, cryptoProvider: DeviceTransferCryptoKeysProviderMock.mock())
  }
}
