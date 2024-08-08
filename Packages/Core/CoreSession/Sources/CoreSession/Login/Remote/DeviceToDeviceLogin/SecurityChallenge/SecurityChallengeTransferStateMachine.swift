import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public struct SecurityChallengeTransferStateMachine: StateMachine {

  public enum State: Hashable, Sendable {
    case initializing

    case readyForTransfer(TransferInfo)

    case transferCompleted(SecurityChallengeKeys)

    case transferError(TransferError)

    case accountRecoveryInfoReady(AccountRecoveryInfo)
  }

  public enum Event: Hashable {
    case requestTransferInfo

    case beginTransfer(TransferInfo)

    case startAccountRecovery
  }

  let login: Login
  let apiClient: AppAPIClient
  let cryptoProvider: DeviceTransferCryptoKeysProvider
  let logger: Logger

  public var state: State = .initializing

  public init(
    login: Login,
    apiClient: AppAPIClient,
    cryptoProvider: DeviceTransferCryptoKeysProvider,
    logger: Logger
  ) {
    self.login = login
    self.apiClient = apiClient
    self.cryptoProvider = cryptoProvider
    self.logger = logger
  }

  public mutating func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch (state, event) {
    case (.initializing, .requestTransferInfo):
      await startTransfer()
    case (.readyForTransfer, let .beginTransfer(info)):
      await transferKeys(with: info)
    case (_, .startAccountRecovery):
      do {
        let info = try await apiClient.accountRecoveryInfo(for: login)
        self.state = .accountRecoveryInfoReady(info)
      } catch {
        self.state = .transferError(.unknown)
      }
    default:
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
  }

  mutating func startTransfer() async {
    do {
      let transferId = try await apiClient.secretTransfer.requestTransfer(
        transfer: AppAPIClient.SecretTransfer.RequestTransfer.Body.Transfer(
          transferType: .universal, receiverDeviceName: Device.localizedName(), login: login.email)
      ).transferId
      let senderPublicKey = try await apiClient.secretTransfer.startReceiverKeyExchange(
        transferId: transferId, receiverHashedPublicKey: cryptoProvider.publicKeyHash()
      ).senderPublicKey
      self.state = .readyForTransfer(
        TransferInfo(transferId: transferId, publicKey: senderPublicKey))
      logger.logInfo("Transition to state: \(state)")
    } catch let error as URLError where error.code == .timedOut {
      logger.error("Transfer failed", error: error)
      state = .transferError(.timeout)
    } catch {
      logger.error("Transfer failed", error: error)
      state = .transferError(.unknown)
    }
  }

  mutating func transferKeys(with info: TransferInfo) async {
    do {
      try await apiClient.secretTransfer.completeKeyExchange(
        transferId: info.transferId, receiverPublicKey: cryptoProvider.publicKeyString)
      let securityChallengeKeys = try cryptoProvider.securityChallengeKeys(
        using: info.publicKey, login: login.email, transferId: info.transferId, origin: .receiver)
      state = .transferCompleted(securityChallengeKeys)
    } catch let error as URLError where error.code == .timedOut {
      logger.error("Transfer key exchange failed", error: error)
      state = .transferError(.timeout)
    } catch {
      logger.error("Transfer key exchange failed", error: error)
      state = .transferError(.unknown)
    }
  }
}

extension SecurityChallengeTransferStateMachine {
  public static var mock: SecurityChallengeTransferStateMachine {
    SecurityChallengeTransferStateMachine(
      login: "_", apiClient: .fake,
      cryptoProvider: DeviceTransferCryptoKeysProviderMock.mock(keys: .mock), logger: LoggerMock())
  }
}

public struct TransferInfo: Hashable, Sendable {
  public let transferId: String
  public let publicKey: String
}
