import Foundation
import Combine
import DashlaneAppKit
import DashlaneReportKit
import SwiftUI
import CoreSettings
import UniformTypeIdentifiers
import CoreSession
import CorePersonalData
import CoreUserTracking
import ImportKit
import DashTypes
import VaultKit

final class GeneralSettingsViewModel: ObservableObject, SessionServicesInjecting {

    static let pasteboardExpirationDelay: TimeInterval = 300

    let userSettings: UserSettings
    let usageLogService: UsageLogServiceProtocol
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

    var displayImportFlow = PassthroughSubject<Void, Never>()

    var importContentTypes: [UTType] {
        return ImportFlowKind.dash.contentTypes
    }

    private var subscriptions = Set<AnyCancellable>()

    let exportSecureArchiveViewModelFactory: ExportSecureArchiveViewModel.Factory

    init(personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder,
         applicationDatabase: ApplicationDatabase,
         databaseDriver: DatabaseDriver,
         iconService: IconServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         userSettings: UserSettings,
         usageLogService: UsageLogServiceProtocol,
         exportSecureArchiveViewModelFactory: ExportSecureArchiveViewModel.Factory) {
        self.userSettings = userSettings
        self.usageLogService = usageLogService
        self.importFlowViewModel = DashImportFlowViewModel(initialStep: nil,
                                                           personalDataURLDecoder: personalDataURLDecoder,
                                                           applicationDatabase: applicationDatabase,
                                                           databaseDriver: databaseDriver,
                                                           iconService: iconService,
                                                           activityReporter: activityReporter)
        self.showImportPasswordView = false
        self.databaseDriver = databaseDriver
        self.activityReporter = activityReporter
        self.exportSecureArchiveViewModelFactory = exportSecureArchiveViewModelFactory

        let expirationDelay: TimeInterval? = userSettings[.clipboardExpirationDelay]
        isClipboardExpirationEnabled = expirationDelay != nil

        _isUniversalClipboardEnabled = UserSetting(key: .isUniversalClipboardEnabled, settings: userSettings, defaultValue: false)
        _isAdvancedSystemIntegrationEnabled = UserSetting(key: .advancedSystemIntegration, settings: userSettings, defaultValue: false)
        _isClipboardOverridden = UserSetting(key: .clipboardOverrideEnabled, settings: userSettings, defaultValue: false) { value in
            usageLogService.post(UsageLogCode35UserActionsMobile(type: "settings", action: "clipboardOverride\(value ? "On" : "Off")"))
        }

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
            self.displayImportFlow.send(())
        case .cancel:
            break
        }
    }
}

extension GeneralSettingsViewModel {
    static var mock: GeneralSettingsViewModel {
        return GeneralSettingsViewModel(
            personalDataURLDecoder: .init(domainParser: DomainParserMock(), linkedDomainService: LinkedDomainService()),
            applicationDatabase: ApplicationDBStack.mock(),
            databaseDriver: InMemoryDatabaseDriver(),
            iconService: IconServiceMock(),
            activityReporter: .fake,
            userSettings: UserSettings(internalStore: InMemoryLocalSettingsStore()),
            usageLogService: UsageLogService.fakeService,
            exportSecureArchiveViewModelFactory: .init({ .mock }))
    }
}
