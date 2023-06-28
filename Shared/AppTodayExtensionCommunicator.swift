import Foundation
import Combine
import CorePersonalData
import DashlaneAppKit
import SwiftTreats
import CoreSettings
import VaultKit

class AppTodayExtensionCommunicator {
    private let applicationContext = TodayApplicationContext()
    private let vaultItemsService: VaultItemsServiceProtocol
    private let syncedSettings: SyncedSettingsService
    private let userSettings: UserSettings
    private let anonymousDeviceId: String
    private var cancellables = Set<AnyCancellable>()
    
    init(vaultItemsService: VaultItemsServiceProtocol,
         syncedSettings: SyncedSettingsService,
         userSettings: UserSettings,
         anonymousDeviceId: String) {
        self.vaultItemsService = vaultItemsService
        self.syncedSettings = syncedSettings
        self.userSettings = userSettings
        self.anonymousDeviceId = anonymousDeviceId
        setup()
    }
    
    func setup() {
        vaultItemsService.$credentials.sink { [weak self] credentials in
            self?.updateTokens(for: credentials)
        }.store(in: &cancellables)
        
        userSettings.settingsChangePublisher.sink { [weak self] key in
            switch key {
            case .advancedSystemIntegration, .clipboardExpirationDelay, .isUniversalClipboardEnabled:
                self?.updateSettings()
            default: break
            }
        }.store(in: &cancellables)
        updateSettings()
    }
    
    func unload() {
        removeTokens()
    }
    
    func updateTokens(for credentials: [Credential]) {
        self.applicationContext.tokens = credentials.compactMap { credential in
            guard let otpUrl = credential.otpURL else {
                return nil
            }
            let title = credential.displayTitle
            let login = credential.displaySubtitle ?? ""
            return TodayApplicationContext.Token(url: otpUrl, title: title, login: login)
        }
        self.sendContext()
    }
    
        private func removeTokens() {
        applicationContext.tokens = []
        sendContext()
    }
    
        private func updateSettings() {
        applicationContext.isClipboardExpirationSet = userSettings[.clipboardExpirationDelay] != nil ?? false
        applicationContext.isUniversalClipboardEnabled = userSettings[.isUniversalClipboardEnabled] ?? false
        applicationContext.advancedSystemIntegration = userSettings[.advancedSystemIntegration] ?? false
        applicationContext.reportHeaderInfo = TodayApplicationContext.ReportHeaderInfo(
            userId: syncedSettings[\.anonymousUserId],
            device: anonymousDeviceId)
        sendContext()
    }
    
        private func sendContext() {
        if !Device.isMac {
            try? applicationContext.toDisk()
        }
    }
    
}
