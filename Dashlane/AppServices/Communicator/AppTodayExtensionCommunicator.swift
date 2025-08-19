import Combine
import CorePersonalData
import CoreSettings
import Foundation
import SwiftTreats
import VaultKit

class AppTodayExtensionCommunicator {
  private let applicationContext = TodayApplicationContext()
  private let vaultItemsStore: VaultItemsStore
  private let syncedSettings: SyncedSettingsService
  private let userSettings: UserSettings
  private let anonymousDeviceId: String
  private var cancellables = Set<AnyCancellable>()

  init(
    vaultItemsStore: VaultItemsStore,
    syncedSettings: SyncedSettingsService,
    userSettings: UserSettings,
    anonymousDeviceId: String
  ) {
    self.vaultItemsStore = vaultItemsStore
    self.syncedSettings = syncedSettings
    self.userSettings = userSettings
    self.anonymousDeviceId = anonymousDeviceId
    setup()
  }

  func setup() {
    vaultItemsStore.$credentials.sink { [weak self] credentials in
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
    applicationContext.isClipboardExpirationSet =
      userSettings[.clipboardExpirationDelay] != nil ?? false
    applicationContext.isUniversalClipboardEnabled =
      userSettings[.isUniversalClipboardEnabled] ?? false
    applicationContext.advancedSystemIntegration = userSettings[.advancedSystemIntegration] ?? false
    applicationContext.reportHeaderInfo = TodayApplicationContext.ReportHeaderInfo(
      userId: syncedSettings[\.anonymousUserId],
      device: anonymousDeviceId)
    sendContext()
  }

  private func sendContext() {
    if !Device.is(.mac) {
      try? applicationContext.toDisk()
    }
  }

}
