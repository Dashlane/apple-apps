import Combine
import CorePersonalData
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit

@MainActor
class PostARKChangeMasterPasswordViewModel: ObservableObject, SessionServicesInjecting {

  enum Completion {
    case finished(Session)
    case cancel
  }

  let accountCryptoChangerService: AccountCryptoChangerServiceProtocol
  let activityReporter: ActivityReporterProtocol
  var dismissPublisher = PassthroughSubject<Void, Never>()
  let completion: (Completion) -> Void
  let userDeviceAPIClient: UserDeviceAPIClient
  let syncedSettings: SyncedSettingsService
  let logger: Logger
  let migrationProgressViewModelFactory: MigrationProgressViewModel.Factory

  init(
    accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
    userDeviceAPIClient: UserDeviceAPIClient,
    syncedSettings: SyncedSettingsService,
    activityReporter: ActivityReporterProtocol,
    logger: Logger,
    migrationProgressViewModelFactory: MigrationProgressViewModel.Factory,
    completion: @escaping (PostARKChangeMasterPasswordViewModel.Completion) -> Void
  ) {
    self.accountCryptoChangerService = accountCryptoChangerService
    self.activityReporter = activityReporter
    self.completion = completion
    self.syncedSettings = syncedSettings
    self.userDeviceAPIClient = userDeviceAPIClient
    self.logger = logger
    self.migrationProgressViewModelFactory = migrationProgressViewModelFactory
    Task {
      accountCryptoChangerService.start()
    }
  }

  func makeMigrationProgressViewModel() -> MigrationProgressViewModel {
    let model = migrationProgressViewModelFactory.make(
      type: .masterPasswordToMasterPassword,
      accountCryptoChangerService: accountCryptoChangerService,
      context: .accountRecovery
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      if case .success(let session) = result {
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
      accountCryptoChangerService: AccountCryptoChangerService.mock,
      userDeviceAPIClient: .fake,
      syncedSettings: .mock,
      activityReporter: .mock,
      logger: LoggerMock(),
      migrationProgressViewModelFactory: .init({ _, _, _, _, _, _ in
        .mock()
      }
      ),
      completion: { _ in }
    )
  }
}
