import Foundation
import Combine
import DashlaneAppKit
import SwiftUI
import CoreSettings
import UniformTypeIdentifiers
import CoreSession
import CorePersonalData
import CoreUserTracking
import ImportKit
import DashTypes
import VaultKit
import DomainParser

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

    let exportSecureArchiveViewModelFactory: ExportSecureArchiveViewModel.Factory

    init(applicationDatabase: ApplicationDatabase,
         databaseDriver: DatabaseDriver,
         iconService: IconServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         userSettings: UserSettings,
         exportSecureArchiveViewModelFactory: ExportSecureArchiveViewModel.Factory,
         dashImportFlowViewModelFactory: DashImportFlowViewModel.SecondFactory) {
        self.userSettings = userSettings
        self.importFlowViewModel = dashImportFlowViewModelFactory.make(shouldHaveInitialStep: false,
                                                                       applicationDatabase: applicationDatabase,
                                                                       databaseDriver: databaseDriver)

        self.showImportPasswordView = false
        self.databaseDriver = databaseDriver
        self.activityReporter = activityReporter
        self.exportSecureArchiveViewModelFactory = exportSecureArchiveViewModelFactory

        let expirationDelay: TimeInterval? = userSettings[.clipboardExpirationDelay]
        isClipboardExpirationEnabled = expirationDelay != nil

        _isUniversalClipboardEnabled = UserSetting(key: .isUniversalClipboardEnabled, settings: userSettings, defaultValue: false)
        _isAdvancedSystemIntegrationEnabled = UserSetting(key: .advancedSystemIntegration, settings: userSettings, defaultValue: false)
        _isClipboardOverridden = UserSetting(key: .clipboardOverrideEnabled, settings: userSettings, defaultValue: false)

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
    static var mock: GeneralSettingsViewModel {
        return GeneralSettingsViewModel(
            applicationDatabase: ApplicationDBStack.mock(),
            databaseDriver: InMemoryDatabaseDriver(),
            iconService: IconServiceMock(),
            activityReporter: .fake,
            userSettings: UserSettings(internalStore: .mock()),
            exportSecureArchiveViewModelFactory: .init({ .mock }),
            dashImportFlowViewModelFactory: .init({ _, _, _  in .mock() }))
    }
}
