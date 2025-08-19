import CorePremium
import CoreSession
import CoreTypes
import Foundation
import Logger
import LoginKit
import StateMachine
import UserTrackingFoundation

@MainActor
final class MP2MPAccountMigrationViewModel: StateMachineBasedObservableObject,
  SessionServicesInjecting
{

  enum Step: Hashable {
    case confirmation
    case passwordInput
    case migrationInProgress(AccountMigrationConfiguration)
  }

  @Published private(set) var steps: [Step] = [.confirmation]
  var stateMachine: MP2MPAccountMigrationStateMachine
  var isPerformingEvent = false

  private let capabilityService: CapabilityServiceProtocol
  private let activityReporter: ActivityReporterProtocol
  private let accountTypeMigrationStateMachineFactory: AccountTypeMigrationStateMachine.Factory
  private let newMasterPasswordViewModelFactory: NewMasterPasswordViewModel.Factory
  private let migrationProgressViewModelFactory: MigrationProgressViewModel.Factory
  private let migrationContext: MigrationProgressViewModel.Context
  private let completion: AccountMigrationCompletion

  lazy private(set) var isSyncAvailable: Bool = {
    self.capabilityService.status(of: .sync).isAvailable
  }()

  init(
    session: Session,
    capabilityService: any CapabilityServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    loginKitServices: LoginKitServicesContainer,
    accountTypeMigrationStateMachineFactory: AccountTypeMigrationStateMachine.Factory,
    migrationProgressViewModelFactory: MigrationProgressViewModel.Factory,
    migrationContext: MigrationProgressViewModel.Context,
    completion: @escaping AccountMigrationCompletion
  ) {
    self.stateMachine = Machine(session: session)
    self.capabilityService = capabilityService
    self.activityReporter = activityReporter
    self.accountTypeMigrationStateMachineFactory = accountTypeMigrationStateMachineFactory
    self.newMasterPasswordViewModelFactory = InjectedFactory(
      loginKitServices.makeNewMasterPasswordViewModel)
    self.migrationProgressViewModelFactory = migrationProgressViewModelFactory
    self.migrationContext = migrationContext
    self.completion = completion
  }

  func makeInitialViewCompletion() -> (MigrationDecision) -> Void {
    return { [weak self] result in
      Task {
        await self?.perform(Machine.Event(result))
      }
    }
  }

  func makeNewMasterPasswordViewModel() -> NewMasterPasswordViewModel {
    return newMasterPasswordViewModelFactory.make(mode: .masterPasswordChange) {
      [weak self] result in
      Task {
        await self?.perform(Machine.Event(result))
      }
    }
  }

  func makeMigrationProgressViewModel(configuration: AccountMigrationConfiguration)
    -> MigrationProgressViewModel
  {
    return migrationProgressViewModelFactory.make(
      context: migrationContext,
      stateMachine: accountTypeMigrationStateMachineFactory.make(
        accountMigrationConfiguration: configuration)
    ) { [weak self] result in
      Task {
        await self?.perform(Machine.Event(result))
      }
    }
  }

  func update(
    for event: MP2MPAccountMigrationStateMachine.Event,
    from oldState: MP2MPAccountMigrationStateMachine.State,
    to newState: MP2MPAccountMigrationStateMachine.State
  ) async {
    switch newState {
    case .confirmation:
      self.steps = [.confirmation]
    case .waitingForMasterPassword:
      activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .start))
      self.steps = [.confirmation, .passwordInput]
    case .migration(let configuration):
      self.steps = [.migrationInProgress(configuration)]
    case .completed(let session):
      activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .complete))
      self.completion(.success(session))
    case .failed(let error):
      activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .error))
      self.completion(.failure(error.underlyingError))
    case .cancelled:
      activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .cancel))
      self.completion(.cancel)
    }
  }
}

extension MP2MPAccountMigrationStateMachine.Event {
  fileprivate init(_ value: MigrationDecision) {
    switch value {
    case .cancel:
      self = .back
    case .migrate:
      self = .enterMasterPassword
    }
  }

  fileprivate init(_ value: NewMasterPasswordViewModel.Completion) {
    switch value {
    case .next(let masterPassword):
      self = .masterPasswordEntered(masterPassword)
    case .back:
      self = .back
    }
  }

  fileprivate init(_ value: Result<Session, Error>) {
    switch value {
    case .success(let session):
      self = .complete(session)
    case .failure(let error):
      self = .fail(error)
    }
  }
}
