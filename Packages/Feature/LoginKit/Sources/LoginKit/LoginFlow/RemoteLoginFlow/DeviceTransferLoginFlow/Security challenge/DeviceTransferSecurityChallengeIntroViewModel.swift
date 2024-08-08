import CoreCrypto
import CoreLocalization
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public class DeviceTransferSecurityChallengeIntroViewModel: ObservableObject,
  LoginKitServicesInjecting
{

  public enum CompletionType {
    case completed(SecurityChallengeKeys)
    case recovery(AccountRecoveryInfo)
    case failure(TransferError)
  }

  @Published
  var isLoading = false

  @Published
  var progressState: ProgressionState = .inProgress(
    L10n.Core.Mpless.D2d.Universal.Untrusted.loadingChallenge)

  let completion: (CompletionType) -> Void

  public var stateMachine: SecurityChallengeTransferStateMachine

  public init(
    login: Login,
    apiClient: AppAPIClient,
    securityChallengeTransferStateMachineFactory: SecurityChallengeTransferStateMachine.Factory,
    completion: @escaping (DeviceTransferSecurityChallengeIntroViewModel.CompletionType) -> Void
  ) {
    let cryptoProvider = DeviceTransferCryptoKeysProviderImpl()
    self.stateMachine = securityChallengeTransferStateMachineFactory.make(
      login: login, cryptoProvider: cryptoProvider)
    self.completion = completion
    Task {
      await perform(.requestTransferInfo)
    }
  }

  func recover() async {
    await perform(.startAccountRecovery)
  }
}

@MainActor
extension DeviceTransferSecurityChallengeIntroViewModel: StateMachineBasedObservableObject {
  public func update(
    for event: SecurityChallengeTransferStateMachine.Event,
    from oldState: SecurityChallengeTransferStateMachine.State,
    to newState: SecurityChallengeTransferStateMachine.State
  ) async {
    switch newState {

    case .initializing: break
    case let .readyForTransfer(transferInfo):
      isLoading = true
      await perform(.beginTransfer(transferInfo))
    case let .transferCompleted(transferKeys):
      completion(.completed(transferKeys))
    case let .transferError(error):
      completion(.failure(error))
    case let .accountRecoveryInfoReady(accountRecoveryInfo):
      completion(.recovery(accountRecoveryInfo))
    }
  }
}

extension DeviceTransferSecurityChallengeIntroViewModel {
  static var mock: DeviceTransferSecurityChallengeIntroViewModel {
    DeviceTransferSecurityChallengeIntroViewModel(
      login: "", apiClient: .fake,
      securityChallengeTransferStateMachineFactory: .init({ _, _ in
        .mock
      })
    ) { _ in }
  }
}
