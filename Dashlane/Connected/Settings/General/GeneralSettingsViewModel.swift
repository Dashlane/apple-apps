import Combine
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import DomainParser
import Foundation
import IconLibrary
import ImportKit
import SwiftUI
import UniformTypeIdentifiers
import UserTrackingFoundation
import VaultKit

@MainActor
final class GeneralSettingsViewModel: ObservableObject, SessionServicesInjecting {

  static let pasteboardExpirationDelay: TimeInterval = 300

  let userSettings: UserSettings
  let importFlowViewModel: DashImportFlowViewModel
  let databaseDriver: DatabaseDriver
  let activityReporter: ActivityReporterProtocol

  @Published
  var isClipboardExpirationEnabled: Bool

  @UserSetting
  var isUniversalClipboardEnabled: Bool

  @UserSetting
  var isAdvancedSystemIntegrationEnabled: Bool

  @UserSetting
  var isClipboardOverridden: Bool

  @Published
  var showImportPasswordView: Bool

  @Published
  var showImportFlow: Bool = false

  var importContentTypes: [UTType] {
    return ImportFlowKind.dash.contentTypes
  }

  private var subscriptions = Set<AnyCancellable>()

  let exportCSVSettingsSectionModelFactory: ExportCSVSettingsSectionModel.Factory
  let secureArchiveSectionViewModelFactory: SecureArchiveSectionViewModel.Factory
  let duplicateItemsViewModelFactory: DuplicateItemsViewModel.Factory

  init(
    applicationDatabase: ApplicationDatabase,
    databaseDriver: DatabaseDriver,
    iconService: IconServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    userSettings: UserSettings,
    exportCSVSettingsSectionModelFactory: ExportCSVSettingsSectionModel.Factory,
    secureArchiveSectionViewModelFactory: SecureArchiveSectionViewModel.Factory,
    dashImportFlowViewModelFactory: DashImportFlowViewModel.SecondFactory,
    duplicateItemsViewModelFactory: DuplicateItemsViewModel.Factory
  ) {
    self.userSettings = userSettings
    self.importFlowViewModel = dashImportFlowViewModelFactory.make(
      shouldHaveInitialStep: false,
      applicationDatabase: applicationDatabase,
      databaseDriver: databaseDriver)

    self.showImportPasswordView = false
    self.databaseDriver = databaseDriver
    self.activityReporter = activityReporter
    self.exportCSVSettingsSectionModelFactory = exportCSVSettingsSectionModelFactory
    self.secureArchiveSectionViewModelFactory = secureArchiveSectionViewModelFactory
    self.duplicateItemsViewModelFactory = duplicateItemsViewModelFactory

    let expirationDelay: TimeInterval? = userSettings[.clipboardExpirationDelay]
    isClipboardExpirationEnabled = expirationDelay != nil

    _isUniversalClipboardEnabled = UserSetting(
      key: .isUniversalClipboardEnabled, settings: userSettings, defaultValue: false)
    _isAdvancedSystemIntegrationEnabled = UserSetting(
      key: .advancedSystemIntegration, settings: userSettings, defaultValue: false)
    _isClipboardOverridden = UserSetting(
      key: .clipboardOverrideEnabled, settings: userSettings, defaultValue: false)

    importFlowViewModel.dismissPublisher.sink { [weak self] action in
      switch action {
      case .dismiss:
        self?.showImportFlow = false
      case .popToRootView:
        break
      }
    }.store(in: &subscriptions)

    $isClipboardExpirationEnabled.sink { newValue in
      userSettings[.clipboardExpirationDelay] = newValue ? Self.pasteboardExpirationDelay : nil
    }
    .store(in: &subscriptions)
  }

  func handleImportFile(_ file: Data) {
    importFlowViewModel.makeImportViewModel(withSecureArchiveData: file)
    showImportPasswordView = true
  }

  func importPasswordViewAction(_ action: DashImportPasswordView.Action) {
    self.importFlowViewModel.handlePasswordAction(action)
    self.showImportPasswordView = false
    switch action {
    case .extracted, .extractionError:
      self.showImportFlow = true
    case .cancel:
      break
    }
  }

}

extension GeneralSettingsViewModel {
  static func mock(status: CorePremium.Status) -> GeneralSettingsViewModel {
    return GeneralSettingsViewModel(
      applicationDatabase: ApplicationDBStack.mock(),
      databaseDriver: InMemoryDatabaseDriver(),
      iconService: IconServiceMock(),
      activityReporter: .mock,
      userSettings: UserSettings(internalStore: .mock()),
      exportCSVSettingsSectionModelFactory: .init({ .mock(status: status) }),
      secureArchiveSectionViewModelFactory: .init({ .mock(status: status) }),
      dashImportFlowViewModelFactory: .init({ _, _, _ in .mock() }),
      duplicateItemsViewModelFactory: .init({ .mock() }))
  }
}
