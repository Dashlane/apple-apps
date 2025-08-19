import Combine
import CorePersonalData
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import LoginKit
import UserTrackingFoundation

@MainActor
class PostARKChangeMasterPasswordViewModel: ObservableObject, SessionServicesInjecting {

  enum Completion {
    case finished(Session)
    case cancel
  }

  let accountMigrationConfiguration: AccountMigrationConfiguration
  let activityReporter: ActivityReporterProtocol
  var dismissPublisher = PassthroughSubject<Void, Never>()
  let completion: (Completion) -> Void
  let userDeviceAPIClient: UserDeviceAPIClient
  let syncedSettings: SyncedSettingsService
  let logger: Logger
  private let accountTypeMigrationStateMachineFactory: AccountTypeMigrationStateMachine.Factory
  let migrationProgressViewModelFactory: MigrationProgressViewModel.Factory

  init(
    accountMigrationConfiguration: AccountMigrationConfiguration,
    userDeviceAPIClient: UserDeviceAPIClient,
    syncedSettings: SyncedSettingsService,
    activityReporter: ActivityReporterProtocol,
    logger: Logger,
    accountTypeMigrationStateMachineFactory: AccountTypeMigrationStateMachine.Factory,
    migrationProgressViewModelFactory: MigrationProgressViewModel.Factory,
    completion: @escaping (PostARKChangeMasterPasswordViewModel.Completion) -> Void
  ) {
    self.accountMigrationConfiguration = accountMigrationConfiguration
    self.activityReporter = activityReporter
    self.completion = completion
    self.syncedSettings = syncedSettings
    self.userDeviceAPIClient = userDeviceAPIClient
    self.logger = logger
    self.accountTypeMigrationStateMachineFactory = accountTypeMigrationStateMachineFactory
    self.migrationProgressViewModelFactory = migrationProgressViewModelFactory
  }

  func makeMigrationProgressViewModel() -> MigrationProgressViewModel {
    let model = migrationProgressViewModelFactory.make(
      context: .accountRecovery,
      stateMachine: accountTypeMigrationStateMachineFactory.make(
        accountMigrationConfiguration: accountMigrationConfiguration)
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      if case .success(let session) = result {
        self.activityReporter.report(UserEvent.UseAccountRecoveryKey(flowStep: .complete))
        self.completion(.finished(session))
      } else {
        self.dismissPublisher.send()
      }
    }
    return model
  }
}

extension PostARKChangeMasterPasswordViewModel {
  static var mock: PostARKChangeMasterPasswordViewModel {
    PostARKChangeMasterPasswordViewModel(
      accountMigrationConfiguration: .mock,
      userDeviceAPIClient: .fake,
      syncedSettings: .mock,
      activityReporter: .mock,
      logger: .mock,
      accountTypeMigrationStateMachineFactory: InjectedFactory {
        .mock(accountMigrationConfiguration: $0)
      },
      migrationProgressViewModelFactory: InjectedFactory { _, _, _ in .mock() },
      completion: { _ in }
    )
  }
}
