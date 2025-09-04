import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

public final class SenderQRCodeService {

  @Loggable
  enum Error: Swift.Error {
    case invalidFormat
  }
  let session: Session
  let apiClient: UserDeviceAPIClient
  let sessionCryptoEngineProvider: CryptoEngineProvider
  let ecdh: ECDHProtocol

  public init(
    session: Session,
    apiClient: UserDeviceAPIClient,
    sessionCryptoEngineProvider: CryptoEngineProvider,
    ecdh: ECDHProtocol
  ) {
    self.session = session
    self.apiClient = apiClient
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.ecdh = ecdh
  }

  public func startTransfer(withQRCode qrCode: String) async throws {
    guard let info = QRCodeInfo(qrCode: qrCode) else {
      throw Error.invalidFormat
    }
    let token = try await apiClient.authentication.token()
    let transferData = DeviceToDeviceTransferData(
      key: session.authenticationMethod.sessionKey.transferKey(
        accountType: session.configuration.info.accountType), token: token,
      login: session.login.email, version: 1)
    try await self.transferData(
      transferData, with: QRCodeInfo(publicKey: info.publicKey, id: info.id))
  }

  private func transferData<T: Encodable>(_ transferData: T, with info: QRCodeInfo) async throws {
    guard let untrustedPublicKey = Data(base64Encoded: info.publicKey) else {
      throw Error.invalidFormat
    }
    let symmetricKey = try ecdh.symmetricKey(
      withPublicKey: untrustedPublicKey, base64EncodedSalt: ApplicationSecrets.MPTransfer.salt)
    let keyString = symmetricKey.withUnsafeBytes {
      return Data(Array($0))
    }
    let cryptoEngine = try sessionCryptoEngineProvider.cryptoEngine(forKey: keyString)
    let data = try JSONEncoder().encode(transferData)
    let encryptedData = try cryptoEngine.encrypt(data)
    try await apiClient.mpless.completeTransfer(
      transferId: info.id,
      encryptedData: encryptedData.base64EncodedString(),
      cryptography: .init(algorithm: .directHKDFSHA256, ellipticCurve: .x25519),
      publicKey: ecdh.publicKeyString)
  }
}

extension UserDeviceAPIClient.Authentication {
  func token() async throws -> String? {
    let twoFAStatus = try await get2FAStatus.callAsFunction()
    if twoFAStatus.type == .emailToken || twoFAStatus.type == .sso {
      let tokenInfo = try await requestExtraDeviceRegistration.callAsFunction(
        tokenType: .shortLived)
      return tokenInfo.token
    }
    return nil
  }
}

extension SenderQRCodeService {
  static var mock: SenderQRCodeService {
    SenderQRCodeService(
      session: .mock, apiClient: .fake, sessionCryptoEngineProvider: .mock(), ecdh: ECDHMock.mock())
  }
}
