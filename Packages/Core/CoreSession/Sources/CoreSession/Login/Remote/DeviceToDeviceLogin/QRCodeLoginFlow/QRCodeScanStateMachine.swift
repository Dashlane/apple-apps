import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public struct QRCodeScanStateMachine: StateMachine {

  public enum State: Hashable, Sendable {
    case waitingForQRCodeScan
    case readyForTransfer(QRCodeTransferInfo)
    case transferring(AppAPIClient.Mpless.StartTransfer.Response)
    case transferCompleted(AccountTransferInfo)
    case transferError(StateMachineError)
  }

  public enum Event: Hashable {
    case requestTransferInfo
    case beginTransfer(withID: String)
    case sendTransferData(response: AppAPIClient.Mpless.StartTransfer.Response)
  }

  public enum Error: Swift.Error {
    case couldNotGeneratePublicKey
    case couldNotDecrypt
    case wrongPublicKeyFormat

  }

  let login: Login?
  let appAPIClient: AppAPIClient
  let sessionCryptoEngineProvider: CryptoEngineProvider
  let qrDeviceTransferCrypto: ECDHProtocol
  let decoder = JSONDecoder()
  let logger: Logger

  public var state: State

  public init(
    login: Login?,
    state: QRCodeScanStateMachine.State,
    appAPIClient: AppAPIClient,
    sessionCryptoEngineProvider: CryptoEngineProvider,
    qrDeviceTransferCrypto: ECDHProtocol,
    logger: Logger
  ) {
    self.login = login
    self.appAPIClient = appAPIClient
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.qrDeviceTransferCrypto = qrDeviceTransferCrypto
    self.state = state
    self.logger = logger
  }

  public mutating func transition(with event: Event) async {
    logger.info("Received \(event) event")
    switch (state, event) {
    case (.waitingForQRCodeScan, .requestTransferInfo):
      await qrCodeTransferInfo()
    case (.readyForTransfer, let .beginTransfer(transferId)):
      await startTransfer(withId: transferId)
    case (.transferring, let .sendTransferData(info)):
      await transferData(with: info)
    default:
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
  }

  private mutating func qrCodeTransferInfo() async {
    do {
      let info = try await appAPIClient.mpless.requestTransfer()
      guard
        let publicKey = qrDeviceTransferCrypto.publicKeyString.addingPercentEncoding(
          withAllowedCharacters: .alphanumerics)
      else {
        throw Error.couldNotGeneratePublicKey
      }
      let accountRecoveryInfo: AccountRecoveryInfo? =
        if let login = login {
          try? await appAPIClient.accountRecoveryInfo(for: login)
        } else {
          nil
        }
      let qrCodeUrl = "dashlane:///mplesslogin?key=\(publicKey)&id=\(info.transferId)"
      state = .readyForTransfer(
        QRCodeTransferInfo(
          qrCodeURL: qrCodeUrl, transferId: info.transferId,
          accountRecoveryInfo: accountRecoveryInfo))
      logger.logInfo("Transition to \(state) state")
    } catch {
      logger.error("Qrcode qdevice transfer failed", error: error)
      state = .transferError(StateMachineError(underlyingError: error))
    }
  }

  private mutating func startTransfer(withId transferId: String) async {
    do {
      let response = try await appAPIClient.mpless.startTransfer(
        transferId: transferId,
        cryptography: .init(algorithm: .directHKDFSHA256, ellipticCurve: .x25519))
      state = .transferring(response)
      logger.logInfo("Transition to \(state) state")
    } catch {
      logger.error("Qrcode device transfer failed", error: error)
      state = .transferError(StateMachineError(underlyingError: error))
    }
  }

  private mutating func transferData(with transferInfo: AppAPIClient.Mpless.StartTransfer.Response)
    async
  {
    do {
      guard let publicKey = transferInfo.publicKey.removingPercentEncoding,
        let trustedPublicKey = Data(base64Encoded: publicKey)
      else {
        throw Error.wrongPublicKeyFormat
      }
      let symmetricKey = try qrDeviceTransferCrypto.symmetricKey(
        withPublicKey: trustedPublicKey, base64EncodedSalt: ApplicationSecrets.MPTransfer.salt)
      let cryptoEngine = try sessionCryptoEngineProvider.cryptoEngine(forKey: symmetricKey)
      guard let data = Data(base64Encoded: transferInfo.encryptedData),
        let decryptedData = try? cryptoEngine.decrypt(data)
      else {
        throw Error.couldNotDecrypt
      }
      let decodedData = try decoder.decode(DeviceToDeviceTransferData.self, from: decryptedData)
      let validData = try await AccountTransferInfo(
        receivedData: decodedData, apiClient: appAPIClient)
      state = .transferCompleted(validData)
      logger.logInfo("Transition to \(state) state")
    } catch {
      logger.error("Qrcode device transfer failed", error: error)
      state = .transferError(StateMachineError(underlyingError: error))
    }
  }
}

extension QRCodeScanStateMachine {
  public static var mock: QRCodeScanStateMachine {
    QRCodeScanStateMachine(
      login: nil,
      state: .waitingForQRCodeScan,
      appAPIClient: .fake,
      sessionCryptoEngineProvider: FakeCryptoEngineProvider(),
      qrDeviceTransferCrypto: ECDHMock.mock(),
      logger: LoggerMock())
  }
}

extension AppAPIClient.Mpless.StartTransfer.Response: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(encryptedData)
    hasher.combine(publicKey)
  }
}
