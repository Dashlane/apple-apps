import Combine
import CoreLocalization
import CoreNetworking
import CorePersonalData
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import SwiftTreats
import UserTrackingFoundation

@MainActor
class MigrationProgressViewModel: StateMachineBasedObservableObject, SessionServicesInjecting {

  enum Context {
    case changeMP
    case accountRecovery
    case accountTypeMigration

    fileprivate var successText: String {
      switch self {
      case .changeMP:
        return L10n.Localizable.changeMasterPasswordSuccessHeadline
      case .accountTypeMigration:
        return L10n.Localizable.accountMigrationProgressFinished
      case .accountRecovery:
        return CoreL10n.recoveryKeyLoginSuccessMessage
      }
    }

    fileprivate var reason: UserDeviceAPIClient.Accountrecovery.Deactivate.Body.Reason {
      switch self {
      case .accountRecovery:
        return .keyUsed
      case .changeMP, .accountTypeMigration:
        return .vaultKeyChange
      }
    }

    fileprivate var isMasterPasswordContext: Bool {
      return switch self {
      case .changeMP, .accountRecovery:
        true
      case .accountTypeMigration:
        false
      }
    }
  }

  struct MigrationAlert: Identifiable {
    enum Reason: String, Hashable {
      case masterPasswordSuccess
      case failure
    }

    let reason: Reason
    let dismissAction: () -> Void

    var id: Reason {
      return reason
    }
  }

  @Published
  private(set) var isProgress = true

  @Published
  private(set) var isSuccess = false

  @Published
  private(set) var progressionText: String

  @Published
  var currentAlert: MigrationAlert?

  private let context: Context
  private let completion: (Result<Session, Error>) -> Void

  var stateMachine: AccountTypeMigrationStateMachine
  var isPerformingEvent = false

  init(
    context: MigrationProgressViewModel.Context,
    stateMachine: AccountTypeMigrationStateMachine,
    completion: @escaping (Result<Session, Error>) -> Void
  ) {
    self.context = context
    self.stateMachine = stateMachine
    self.completion = completion
    progressionText =
      context == .accountRecovery
      ? CoreL10n.recoveryKeyLoginProgressMessage
      : L10n.Localizable.accountMigrationProgressDownLoading
  }

  func start() {
    Task {
      let (progressStream, progressContinuation) = AccountTypeMigrationStateMachine.ProgressStream
        .makeStream()

      Task {
        for await progress in progressStream {
          self.didProgress(progress)
        }
      }

      await self.perform(.migrate(context.reason, progressContinuation))
    }
  }

  func update(
    for event: AccountTypeMigrationStateMachine.Event,
    from oldState: AccountTypeMigrationStateMachine.State,
    to newState: AccountTypeMigrationStateMachine.State
  ) async {
    switch newState {
    case .initial:
      break
    case .complete(let session):
      complete(with: session)
    case .failed(let error):
      complete(with: error.underlyingError)
    }
  }
}

extension MigrationProgressViewModel {
  func didProgress(_ progression: AccountTypeMigrationStateMachine.Progress) {
    guard context != .accountRecovery else {
      progressionText = CoreL10n.recoveryKeyLoginProgressMessage
      return
    }
    switch progression {
    case .downloading:
      progressionText = L10n.Localizable.accountMigrationProgressDownLoading
    case .decrypting, .encrypting:
      progressionText = L10n.Localizable.accountMigrationProgressEncrypting
    case .uploading: break
    case .finalizing:
      progressionText = L10n.Localizable.accountMigrationProgressFinalizing
    }
  }

  private func complete(with session: Session) {
    self.isProgress = false
    self.isSuccess = true
    self.progressionText = context.successText
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      guard let self = self else {
        return
      }

      if context.isMasterPasswordContext, Device.is(.mac) {
        self.currentAlert = .init(reason: .masterPasswordSuccess) { [weak self] in
          self?.completion(.success(session))
        }
      } else {
        completion(.success(session))
      }
    }
  }

  private func complete(with error: any Error) {
    self.isProgress = false
    self.isSuccess = false
    self.progressionText = L10n.Localizable.changeMasterPasswordErrorTitle
    self.completion(.failure(AccountError.unknown))
  }
}

extension AccountCryptoChangerError {

  fileprivate var userTrackingErrorName: Definition.ChangeMasterPasswordError {
    switch self {
    case .syncFailed:
      return .syncFailedError

    case .finalizationFailed:
      return .confirmationError

    case .encryptionError(let error):
      switch error.progression {
      case .downloading:
        return .downloadError
      case .decrypting:
        return .decipherError
      case .encrypting:
        return .cipherError
      case .uploading:
        return .uploadError
      case .finalizing:
        return .confirmationError
      }
    }
  }
}

extension MigrationProgressViewModel {
  static func mock(complete: Bool = false) -> MigrationProgressViewModel {
    let mock = MigrationProgressViewModel(
      context: .changeMP, stateMachine: .mock(accountMigrationConfiguration: .mock)
    ) { _ in }
    mock.isProgress = complete == false
    mock.isSuccess = complete
    return mock
  }
}
