import Combine
import CoreFeature
import CoreNetworking
import CorePremium
import CoreSession
import CoreSettings
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit
import NotificationKit
import SwiftUI
import UIDelight

@MainActor
final class MainSettingsViewModel: ObservableObject, SessionServicesInjecting {

  let session: Session

  let settingsStatusSectionViewModelFactory: SettingsStatusSectionViewModel.Factory
  let accountSummaryViewModelFactory: AccountSummaryViewModel.Factory
  let addNewDeviceFactory: AddNewDeviceViewModel.Factory

  let userSettings: UserSettings
  private let sessionCryptoEngineProvider: CryptoEngineProvider
  private let lockService: LockServiceProtocol
  private let featureService: FeatureServiceProtocol
  private let userDeviceAPIClient: UserDeviceAPIClient
  private let appAPIClient: AppAPIClient

  init(
    session: Session,
    sessionCryptoEngineProvider: SessionCryptoEngineProvider,
    lockService: LockServiceProtocol,
    userSettings: UserSettings,
    featureService: FeatureServiceProtocol,
    userDeviceAPIClient: UserDeviceAPIClient,
    appAPIClient: AppAPIClient,
    settingsStatusSectionViewModelFactory: SettingsStatusSectionViewModel.Factory,
    accountSummaryViewModelFactory: AccountSummaryViewModel.Factory,
    addNewDeviceFactory: AddNewDeviceViewModel.Factory
  ) {
    self.session = session
    self.lockService = lockService
    self.userSettings = userSettings
    self.featureService = featureService
    self.settingsStatusSectionViewModelFactory = settingsStatusSectionViewModelFactory
    self.accountSummaryViewModelFactory = accountSummaryViewModelFactory
    self.userDeviceAPIClient = userDeviceAPIClient
    self.appAPIClient = appAPIClient
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.addNewDeviceFactory = addNewDeviceFactory
  }

  @Published
  var activityItem: ActivityItem?

  func lock() {
    lockService.locker.screenLocker?.secureLock()
  }

  var login: Login {
    session.login
  }

  func inviteFriends() {
    Task {
      let userKey = try await userDeviceAPIClient.premium.getSubscriptionCode().subscriptionCode
      let sharingID = try await appAPIClient.invitation.getSharingLink(userKey: userKey).sharingId
      let url = "_\(System.language)/im/\(sharingID)"
      let inviteText = L10n.Localizable.kwInviteEmailBody(url)
      activityItem = ActivityItem(items: inviteText)
    }
  }

  var shouldDisplayLabs: Bool {
    featureService.isLabsAvailable
  }

  func makeAddNewDeviceViewModel() -> AddNewDeviceViewModel {
    return addNewDeviceFactory.make()
  }

  static func mock() -> MainSettingsViewModel {
    return MainSettingsViewModel(
      session: Session.mock,
      sessionCryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()),
      lockService: LockServiceMock(),
      userSettings: UserSettings(internalStore: .mock()),
      featureService: .mock(),
      userDeviceAPIClient: UserDeviceAPIClient.fake,
      appAPIClient: .mock({}),
      settingsStatusSectionViewModelFactory: .init({ .mock(status: .Mock.premiumWithAutoRenew) }),
      accountSummaryViewModelFactory: .init({ .mock }),
      addNewDeviceFactory: .init({ _ in .mock(accountType: .masterPassword) }))
  }
}
