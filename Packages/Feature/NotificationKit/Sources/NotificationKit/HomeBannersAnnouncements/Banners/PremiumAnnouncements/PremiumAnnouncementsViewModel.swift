import Combine
import CoreFeature
import CoreLocalization
import CorePremium
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats
import UIKit

public enum PremiumAnnouncement: Hashable, Comparable {
  case passwordLimitReached
  case passwordLimitNearlyReached(remainingItems: Int)
  case autorenewalFailedAnnouncement
  case specialOfferAnnouncement
  case premiumExpiredAnnouncement
  case premiumWillExpireAnnouncement

  fileprivate var id: String {
    switch self {
    case .passwordLimitReached: return "passwordLimitReached"
    case .passwordLimitNearlyReached: return "passwordLimitNearlyReached"
    case .autorenewalFailedAnnouncement: return "autorenewalFailedAnnouncement"
    case .specialOfferAnnouncement: return "specialOfferAnnouncement"
    case .premiumExpiredAnnouncement: return "premiumExpiredAnnouncement"
    case .premiumWillExpireAnnouncement: return "premiumWillExpireAnnouncement"
    }
  }

  fileprivate static var passwordLimitNearlyReachedID: String {
    PremiumAnnouncement.passwordLimitNearlyReached(remainingItems: -1).id
  }
}

public enum ItemsLimit {
  case limited
  case nearlyLimited(remaining: Int)
}

public protocol ItemsLimitNotificationProvider {
  func passwordLimitPublisher() -> AnyPublisher<ItemsLimit?, Never>
}

struct ItemsLimitNotificationProviderMock: ItemsLimitNotificationProvider {

  let passwordLimit: ItemsLimit?

  func passwordLimitPublisher() -> AnyPublisher<ItemsLimit?, Never> {
    Just(passwordLimit).eraseToAnyPublisher()
  }
}

extension ItemsLimitNotificationProvider where Self == ItemsLimitNotificationProviderMock {
  static func mock(passwordLimit: ItemsLimit? = nil) -> ItemsLimitNotificationProvider {
    ItemsLimitNotificationProviderMock(passwordLimit: passwordLimit)
  }
}

@MainActor
public class PremiumAnnouncementsViewModel: ObservableObject, HomeAnnouncementsServicesInjecting {
  let premiumStatusProvider: PremiumStatusProvider
  let hasDiscountPublisher: AnyPublisher<Bool, Never>
  let featureService: FeatureServiceProtocol
  let sessionActivityReporter: ActivityReporterProtocol
  let itemsLimitNotificationProvider: ItemsLimitNotificationProvider

  @Published
  public var announcements: [PremiumAnnouncement] = []
  private var subscriptions = Set<AnyCancellable>()
  let deeplinkService: NotificationKitDeepLinkingServiceProtocol
  let userDeviceAPI: UserDeviceAPIClient

  private var excludedAnnouncements: Set<PremiumAnnouncement>

  var premiumWillExpireTitle: String {
    guard let days = premiumStatusProvider.status.b2cStatus.daysToExpiration() else {
      return ""
    }

    if days == 1 {
      return L10n.Core.announcePremiumExpiring1DayBody
    } else {
      return L10n.Core.announcePremiumExpiringNDaysBody(days)
    }
  }

  var isPremiumTrial: Bool {
    return premiumStatusProvider.status.b2cStatus.isTrial
  }

  var premiumWillExpireSoon: Bool {
    guard let days = premiumStatusProvider.status.b2cStatus.daysToExpiration() else {
      return false
    }

    return days < 15
  }

  public init(
    premiumStatusProvider: PremiumStatusProvider,
    productInfoUpdater: ProductInfoUpdater,
    featureService: FeatureServiceProtocol,
    deeplinkService: NotificationKitDeepLinkingServiceProtocol,
    sessionActivityReporter: ActivityReporterProtocol,
    itemsLimitNotificationProvider: ItemsLimitNotificationProvider,
    userDeviceAPI: UserDeviceAPIClient,
    excludedAnnouncements: Set<PremiumAnnouncement> = []
  ) {
    self.premiumStatusProvider = premiumStatusProvider
    self.hasDiscountPublisher = productInfoUpdater.$hasDiscountAvailable.eraseToAnyPublisher()
    self.featureService = featureService
    self.deeplinkService = deeplinkService
    self.sessionActivityReporter = sessionActivityReporter
    self.userDeviceAPI = userDeviceAPI
    self.itemsLimitNotificationProvider = itemsLimitNotificationProvider
    self.excludedAnnouncements = excludedAnnouncements
    setup()
  }

  private init(
    premiumStatusProvider: PremiumStatusProvider,
    featureService: FeatureServiceProtocol,
    sessionActivityReporter: ActivityReporterProtocol,
    itemsLimitNotificationProvider: ItemsLimitNotificationProvider,
    deeplinkService: NotificationKitDeepLinkingServiceProtocol,
    userDeviceAPI: UserDeviceAPIClient,
    announcements: [PremiumAnnouncement]
  ) {
    self.premiumStatusProvider = premiumStatusProvider
    self.hasDiscountPublisher = Just(false).eraseToAnyPublisher()
    self.featureService = featureService
    self.deeplinkService = deeplinkService
    self.sessionActivityReporter = sessionActivityReporter
    self.userDeviceAPI = userDeviceAPI
    self.itemsLimitNotificationProvider = itemsLimitNotificationProvider
    self.excludedAnnouncements = []
    self.announcements = announcements
  }

  func setup() {
    premiumStatusProvider
      .statusPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        guard let self else {
          return
        }

        guard
          status.b2bStatus?.statusCode != .inTeam
            && status.b2cStatus.statusCode != .legacy
            && status.b2cStatus.familyStatus?.isAdmin != false
        else {
          announcements = []
          return
        }

        self.setupPremiumWillExpireAnnouncement(with: status.b2cStatus)
        self.setupPremiumExpiredAnnouncement(with: status.b2cStatus)
        self.setupAutoRenewalFailedAnnouncement(with: status.b2cStatus)
      }
      .store(in: &subscriptions)

    hasDiscountPublisher.receive(on: DispatchQueue.main).sink { [weak self] value in
      guard let self = self else { return }
      if value {
        self.addAnnouncement(.specialOfferAnnouncement)
      } else {
        self.removeAnnouncement(.specialOfferAnnouncement)
      }
    }.store(in: &subscriptions)

    itemsLimitNotificationProvider.passwordLimitPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] limit in
        guard let self = self else { return }
        self.setupPasswordLimitAnnouncement(limit: limit)
      }
      .store(in: &subscriptions)
  }

  func setupPremiumWillExpireAnnouncement(with status: CorePremium.Status.B2cStatus) {
    guard !status.autoRenewal,
      status.statusCode == .subscribed,
      let daysToExpiration = status.daysToExpiration(),
      daysToExpiration > 0 && daysToExpiration <= 30
    else {
      removeAnnouncement(.premiumWillExpireAnnouncement)
      return
    }
    addAnnouncement(.premiumWillExpireAnnouncement)
  }

  func setupPremiumExpiredAnnouncement(with status: CorePremium.Status.B2cStatus) {
    guard status.statusCode == .free,
      let daysSinceExpiration = status.previousPlan?.daysSinceExpiration(),
      daysSinceExpiration <= 15 && daysSinceExpiration >= 0
    else {
      removeAnnouncement(.premiumExpiredAnnouncement)
      return
    }
    addAnnouncement(.premiumExpiredAnnouncement)
  }

  private func setupAutoRenewalFailedAnnouncement(with status: CorePremium.Status.B2cStatus) {
    Task {
      guard !featureService.isEnabled(.disableAutorenewalAnnouncement),
        status.autoRenewal == true,
        status.planType == .iosRenewable,
        case let subscriptionInfo = try await userDeviceAPI.premium.getSubscriptionInfo(),
        subscriptionInfo.b2cSubscription.autoRenewInfo.reality
          && !subscriptionInfo.b2cSubscription.autoRenewInfo.theory
      else {
        removeAnnouncement(.autorenewalFailedAnnouncement)
        return
      }
      addAnnouncement(.autorenewalFailedAnnouncement)
    }
  }

  private func setupPasswordLimitAnnouncement(limit: ItemsLimit?) {

    switch limit {
    case let .nearlyLimited(remaining):
      if !announcements.contains(where: {
        $0 == .passwordLimitNearlyReached(remainingItems: remaining)
      }) {
        removeAnnouncement(.passwordLimitReached)
        removeAnnouncement(withIdentifier: PremiumAnnouncement.passwordLimitNearlyReachedID)
        addAnnouncement(.passwordLimitNearlyReached(remainingItems: remaining))
      }
    case .limited:
      removeAnnouncement(withIdentifier: PremiumAnnouncement.passwordLimitNearlyReachedID)
      if !announcements.contains(where: { $0 == .passwordLimitReached }) {
        addAnnouncement(.passwordLimitReached)
      }
    case .none:
      removeAnnouncement(.passwordLimitReached)
      removeAnnouncement(withIdentifier: PremiumAnnouncement.passwordLimitNearlyReachedID)
    }
  }

  private func addAnnouncement(_ announcement: PremiumAnnouncement) {
    guard !excludedAnnouncements.contains(announcement) else {
      return
    }
    announcements = Set(announcements + [announcement]).sorted()
  }

  func showSettings() {
    deeplinkService.handle(.goToSettings(.root))
  }

  func showSystemSettings() {
    let url: URL
    if Device.isMac {
      url = URL(fileURLWithPath: "/System/Library/PreferencePanes/SoftwareUpdate.prefPane")
    } else {
      url = URL(string: "App-prefs:root=General")!
    }
    UIApplication.shared.open(url)
  }

  func showPremium(capability: CapabilityKey? = nil) {
    guard let capability = capability else {
      deeplinkService.handle(.goToPremium)
      return
    }
    deeplinkService.handle(.displayPaywall(capability))
  }

  func removeAnnouncement(_ announcement: PremiumAnnouncement) {
    announcements = announcements.filter { $0 != announcement }
  }

  func removeAnnouncement(withIdentifier id: String) {
    announcements = announcements.filter { $0.id != id }
  }

  func openAppleUpdatePaymentsPage() {
    let url = URL(string: "_")!
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }

  func showPremiumForPasswordLimitReached() {
    let event = UserEvent.Click(
      button: .buyDashlane,
      clickOrigin: .bannerPasswordLimitReached)
    sessionActivityReporter.report(event)
    showPremium(capability: .passwordsLimit)
  }

  func showPremiumForPasswordLimitNearlyReached() {
    let event = UserEvent.Click(
      button: .buyDashlane,
      clickOrigin: .bannerPasswordLimitCloseToBeReached)
    sessionActivityReporter.report(event)
    showPremium(capability: .passwordsLimit)
  }
}

extension PremiumAnnouncementsViewModel {

  public static func mock(announcements: [PremiumAnnouncement]) -> PremiumAnnouncementsViewModel {
    let model = PremiumAnnouncementsViewModel(
      premiumStatusProvider: .mock(status: .Mock.premiumWithoutAutoRenew),
      featureService: .mock(),
      sessionActivityReporter: .mock,
      itemsLimitNotificationProvider: .mock(),
      deeplinkService: NotificationKitDeepLinkingServiceMock(),
      userDeviceAPI: .fake,
      announcements: announcements)
    return model
  }
}
