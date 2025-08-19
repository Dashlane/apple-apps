import CoreCrypto
import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats
import UIDelight
import UserTrackingFoundation

@MainActor
public class DeviceTransferSecurityChallengeFlowModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  enum Step {
    case intro(SecurityChallengeTransferStateMachine.State)
    case passphrase(PassphraseVerificationStateMachine.State, SecurityChallengeKeys)
  }

  @Published
  var steps: [Step] = []

  @Published
  var isInProgress = false

  @Published
  var error: TransferError?

  @Published
  var progressState: ProgressionState = .inProgress(CoreL10n.deviceToDeviceLoginProgress)

  @Published public var stateMachine: SecurityChallengeFlowStateMachine
  @Published public var isPerformingEvent: Bool = false

  let login: Login
  let completion: @MainActor (DeviceTransferCompletion) -> Void
  let securityChallengeIntroViewModelFactory: DeviceTransferSecurityChallengeIntroViewModel.Factory
  let passphraseViewModelFactory: DeviceTransferPassphraseViewModel.Factory

  public init(
    login: Login,
    stateMachine: SecurityChallengeFlowStateMachine,
    securityChallengeIntroViewModelFactory: DeviceTransferSecurityChallengeIntroViewModel.Factory,
    passphraseViewModelFactory: DeviceTransferPassphraseViewModel.Factory,
    completion: @escaping @MainActor (DeviceTransferCompletion) -> Void
  ) {
    self.login = login
    self.stateMachine = stateMachine
    self.completion = completion
    self.securityChallengeIntroViewModelFactory = securityChallengeIntroViewModelFactory
    self.passphraseViewModelFactory = passphraseViewModelFactory
    Task {
      await self.perform(.startTransfer)
    }
  }
}

extension DeviceTransferSecurityChallengeFlowModel {
  func makeSecurityChallengeIntroViewModel() -> DeviceTransferSecurityChallengeIntroViewModel {
    securityChallengeIntroViewModelFactory.make(
      login: login,
      stateMachine: stateMachine.makeSecurityChallengeTransferStateMachine(
        login: login, cryptoProvider: DeviceTransferCryptoKeysProviderImpl())
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case let .completed(transferKeys):
        Task {
          await self.perform(.keysAndPassphraseReady(transferKeys))
        }
      case let .recovery(info):
        Task {
          self.completion(.recovery(info))
        }
      case let .failure(error):
        self.error = error
      }
    }
  }

  func makePassphraseViewModel(
    state: PassphraseVerificationStateMachine.State, securityChallengeKeys: SecurityChallengeKeys
  ) -> DeviceTransferPassphraseViewModel {
    passphraseViewModelFactory.make(
      stateMachine: stateMachine.makePassphraseVerificationStateMachine(
        state: state, transferId: securityChallengeKeys.transferId,
        secretBox: DeviceTransferSecretBoxImpl(
          cryptoEngine: DeviceTransferCryptoEngine(symmetricKey: securityChallengeKeys.symmetricKey)
        )),
      words: securityChallengeKeys.passphrase
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        switch result {
        case let .completed(data):
          await self.perform(.transferDataReceived(data))
        case .cancel:
          await self.perform(.cancelChallenge)
        case let .failure(error):
          self.error = error
        }
      }
    }
  }
}

@MainActor
extension DeviceTransferSecurityChallengeFlowModel {
  public func update(
    for event: SecurityChallengeFlowStateMachine.Event,
    from oldState: SecurityChallengeFlowStateMachine.State,
    to newState: SecurityChallengeFlowStateMachine.State
  ) {
    switch newState {
    case .startSecurityChallengeTransfer:
      self.steps.append(.intro(.initializing))
    case let .startPassphraseVerification(state, keys):
      self.steps.append(.passphrase(state, keys))
    case .challengeCancelled:
      self.completion(.dismiss)
    case let .transferComplete(data):
      self.completion(.completed(data))
    case .challengeFailed:
      progressState = .failed("") {
        self.error = .unknown
      }
    }
  }
}
