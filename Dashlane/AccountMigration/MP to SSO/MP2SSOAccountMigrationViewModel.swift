import CoreSession
import CoreTypes
import DashlaneAPI
import Logger
import LoginKit
import StateMachine
import SwiftUI

@MainActor
final class MP2SSOAccountMigrationViewModel: StateMachineBasedObservableObject,
  SessionServicesInjecting
{

  enum Step: Hashable {
    case confirmation
    case ssoAuthentication(SSOAuthenticationInfo)
    case migrationInProgress(AccountMigrationConfiguration)
  }

  @Published private(set) var steps: [Step] = [.confirmation]
  var stateMachine: MP2SSOAccountMigrationStateMachine
  var isPerformingEvent = false

  private let accountTypeMigrationStateMachineFactory: AccountTypeMigrationStateMachine.Factory
  private let ssoViewModelFactory: SSOViewModel.Factory
  private let migrationProgressViewModelFactory: MigrationProgressViewModel.Factory
  private let completion: AccountMigrationCompletion

  init(
    migrationInfos: AccountMigrationInfos,
    session: Session,
    appAPIClient: AppAPIClient,
    accountTypeMigrationStateMachineFactory: AccountTypeMigrationStateMachine.Factory,
    sessionCryptoEngineProvider: SessionCryptoEngineProvider,
    loginKitServices: LoginKitServicesContainer,
    migrationProgressViewModelFactory: MigrationProgressViewModel.Factory,
    completion: @escaping AccountMigrationCompletion
  ) {
    self.stateMachine = MP2SSOAccountMigrationStateMachine(
      session: session,
      migrationInfos: migrationInfos,
      appAPIClient: appAPIClient,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider
    )
    self.accountTypeMigrationStateMachineFactory = accountTypeMigrationStateMachineFactory
    self.ssoViewModelFactory = InjectedFactory(loginKitServices.makeSSOViewModel)
    self.migrationProgressViewModelFactory = migrationProgressViewModelFactory
    self.completion = completion
  }

  func makeInitialViewCompletion() -> (MigrationDecision) -> Void {
    return { [weak self] result in
      Task {
        await self?.perform(MP2SSOAccountMigrationStateMachine.Event(result))
      }
    }
  }

  func makeSSOViewModel(with ssoAuthenticationInfo: SSOAuthenticationInfo) -> SSOViewModel {
    return ssoViewModelFactory.make(ssoAuthenticationInfo: ssoAuthenticationInfo) {
      [weak self] result in
      Task {
        await self?.handleSSOCompletion(result)
      }
    }
  }

  private func handleSSOCompletion(_ result: Result<SSOCompletion, Error>) async {
    switch result {
    case .success(.completed(let callbackInfos)):
      await perform(.ssoAuthenticationCompleted(callbackInfos))
    case .success(.cancel):
      await perform(.back)
    case .failure(let error):
      await perform(.failed(error))
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
      Task {
        await self?.perform(MP2SSOAccountMigrationStateMachine.Event(result))
      }
    }
  }

  func update(
    for event: MP2SSOAccountMigrationStateMachine.Event,
    from oldState: MP2SSOAccountMigrationStateMachine.State,
    to newState: MP2SSOAccountMigrationStateMachine.State
  ) async {
    switch newState {
    case .confirmation:
      self.steps = [.confirmation]
    case .ssoAuthentication(let info):
      self.steps = [.confirmation, .ssoAuthentication(info)]
    case .migration(let configuration):
      self.steps = [.migrationInProgress(configuration)]
    case .completed(let session):
      self.completion(.success(session))
    case .failed(let error):
      self.completion(.failure(error.underlyingError))
    case .cancelled:
      self.completion(.cancel)
    }
  }
}

extension MP2SSOAccountMigrationStateMachine.Event {
  fileprivate init(_ value: Result<Session, any Error>) {
    switch value {
    case .success(let session):
      self = .migrationCompleted(session)
    case .failure(let error):
      self = .failed(error)
    }
  }

  fileprivate init(_ value: MigrationDecision) {
    switch value {
    case .cancel:
      self = .back
    case .migrate:
      self = .startSSOAuthentication
    }
  }
}
