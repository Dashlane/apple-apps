import CoreSession
import CoreTypes
import DashlaneAPI
import LoginKit
import StateMachine
import SwiftUI

@MainActor
final class SSO2MPAccountMigrationViewModel: StateMachineBasedObservableObject,
  SessionServicesInjecting
{

  enum Step {
    case confirmation
    case ssoAuthentication(SSOAuthenticationInfo)
    case masterPasswordCreation
    case migrationInProgress(AccountMigrationConfiguration)
  }

  @Published private(set) var steps: [Step] = [.confirmation]

  private let accountTypeMigrationStateMachineFactory: AccountTypeMigrationStateMachine.Factory
  private let ssoViewModelFactory: SSOViewModel.Factory
  private let newMasterPasswordViewModelFactory: NewMasterPasswordViewModel.Factory
  private let migrationProgressViewModelFactory: MigrationProgressViewModel.Factory
  private let completion: AccountMigrationCompletion

  var stateMachine: SSO2MPAccountMigrationStateMachine
  var isPerformingEvent = false

  init(
    session: Session,
    migrationInfos: AccountMigrationInfos,
    appAPIClient: AppAPIClient,
    userDeviceAPIClient: UserDeviceAPIClient,
    accountTypeMigrationStateMachineFactory: AccountTypeMigrationStateMachine.Factory,
    loginKitServices: LoginKitServicesContainer,
    migrationProgressViewModelFactory: MigrationProgressViewModel.Factory,
    completion: @escaping AccountMigrationCompletion
  ) {
    self.stateMachine = SSO2MPAccountMigrationStateMachine(
      session: session,
      migrationInfos: migrationInfos,
      appAPIClient: appAPIClient,
      userDeviceAPIClient: userDeviceAPIClient
    )

    self.accountTypeMigrationStateMachineFactory = accountTypeMigrationStateMachineFactory
    self.ssoViewModelFactory = InjectedFactory(loginKitServices.makeSSOViewModel)
    self.newMasterPasswordViewModelFactory = InjectedFactory(
      loginKitServices.makeNewMasterPasswordViewModel)
    self.migrationProgressViewModelFactory = migrationProgressViewModelFactory
    self.completion = completion
  }

  func makeInitialViewCompletion() -> (MigrationDecision) -> Void {
    return { [weak self] result in
      self?.performAsync(SSO2MPAccountMigrationStateMachine.Event(result))
    }
  }

  func makeSSOViewModel(with ssoAuthenticationInfo: SSOAuthenticationInfo) -> SSOViewModel {
    return ssoViewModelFactory.make(ssoAuthenticationInfo: ssoAuthenticationInfo) {
      [weak self] result in
      self?.performAsync(SSO2MPAccountMigrationStateMachine.Event(result))
    }
  }

  func makeNewMasterPasswordViewModel() -> NewMasterPasswordViewModel {
    return newMasterPasswordViewModelFactory.make(mode: .masterPasswordChange) {
      [weak self] result in
      self?.performAsync(SSO2MPAccountMigrationStateMachine.Event(result))
    }
  }

  func makeMigrationProgressViewModel(configuration: AccountMigrationConfiguration)
    -> MigrationProgressViewModel
  {
    return migrationProgressViewModelFactory.make(
      context: .accountTypeMigration,
      stateMachine: accountTypeMigrationStateMachineFactory.make(
        accountMigrationConfiguration: configuration)
    ) { [weak self] result in
      self?.performAsync(SSO2MPAccountMigrationStateMachine.Event(result))
    }
  }

  private func performAsync(_ event: SSO2MPAccountMigrationStateMachine.Event) {
    Task {
      await perform(event)
    }
  }

  func update(
    for event: SSO2MPAccountMigrationStateMachine.Event,
    from oldState: SSO2MPAccountMigrationStateMachine.State,
    to newState: SSO2MPAccountMigrationStateMachine.State
  ) async {
    switch newState {
    case .confirmation:
      steps = [.confirmation]

    case .masterPasswordCreation:
      steps = [.confirmation, .masterPasswordCreation]

    case .ssoAuthentication(let ssoAuthenticationInfo):
      if case .masterPasswordCreation = oldState {
        steps = [
          .confirmation, .masterPasswordCreation,
          .ssoAuthentication(ssoAuthenticationInfo),
        ]
      } else {
        steps = [.confirmation, .ssoAuthentication(ssoAuthenticationInfo)]
      }

    case .migration(let configuration):
      steps = [.migrationInProgress(configuration)]

    case .completed(let session):
      completion(.success(session))

    case .failed(let error):
      completion(.failure(error.underlyingError))

    case .cancelled:
      completion(.cancel)
    }
  }
}

extension SSO2MPAccountMigrationStateMachine.Event {
  init(_ value: MigrationDecision) {
    switch value {
    case .migrate:
      self = .startMigration
    case .cancel:
      self = .cancel
    }
  }

  init(_ value: Result<SSOCompletion, any Error>) {
    switch value {
    case .success(.completed(let callbackInfos)):
      self = .ssoAuthenticationCompleted(callbackInfos)
    case .success(.cancel):
      self = .cancel
    case .failure(let error):
      self = .failed(error)
    }
  }

  init(_ value: NewMasterPasswordViewModel.Completion) {
    switch value {
    case .next(let masterPassword):
      self = .migrate(masterPassword)
    case .back:
      self = .cancel
    }
  }

  init(_ value: Result<Session, any Error>) {
    switch value {
    case .success(let session):
      self = .complete(session)
    case .failure(let error):
      self = .failed(error)
    }
  }
}
