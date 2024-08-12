import Combine
import CoreFeature
import CoreSession
import CoreSettings
import DashTypes
import Foundation
import SwiftTreats

@MainActor
public class HomeTopBannerViewModel: ObservableObject, HomeAnnouncementsServicesInjecting {
  enum Banner {
    case frozen
    case authenticatorSunset
    case premium
    case lastpassImport
  }

  @Published var additionnalBanner: Banner?
  @Published var shouldShowLastpassBanner: Bool
  @Published var hasDismissedAuthenticatorSunsetBanner: Bool

  let premiumAnnouncementsViewModel: PremiumAnnouncementsViewModel
  let autofillBannerViewModel: AutofillBannerViewModel
  let frozenBannerViewModel: FrozenBannerViewModel
  let authenticatorSunsetBannerViewModel: AuthenticatorSunsetBannerViewModel
  let lastpassImportBannerViewModel: LastpassImportBannerViewModel
  private let credentialsCount: Int
  private let userSettings: UserSettings
  private let featureService: FeatureServiceProtocol
  private let isLastpassInstalled: Bool

  private var shouldShowPremiumBannerView: Bool {
    hasPremiumAnnouncements
  }

  private let updatePublisher = PassthroughSubject<Void, Never>()
  private var subscriptions: Set<AnyCancellable> = .init()

  public init(
    autofillBannerViewModel: AutofillBannerViewModel,
    authenticatorSunsetBannerViewModel: AuthenticatorSunsetBannerViewModel,
    deeplinkingService: NotificationKitDeepLinkingServiceProtocol,
    userSettings: UserSettings,
    featureService: FeatureServiceProtocol,
    isLastpassInstalled: Bool,
    credentialsCount: Int,
    premiumFactory: PremiumAnnouncementsViewModel.Factory
  ) {
    self.autofillBannerViewModel = autofillBannerViewModel
    self.authenticatorSunsetBannerViewModel = authenticatorSunsetBannerViewModel
    self.userSettings = userSettings
    self.featureService = featureService
    self.lastpassImportBannerViewModel = .init(
      deeplinkingService: deeplinkingService,
      userSettings: userSettings
    )
    self.frozenBannerViewModel = .init(deeplinkingService: deeplinkingService)

    self.credentialsCount = credentialsCount
    self.premiumAnnouncementsViewModel = premiumFactory.make()
    self.isLastpassInstalled = isLastpassInstalled
    self.shouldShowLastpassBanner =
      featureService.isEnabled(.lastpassImport)
      && userSettings[.lastpassImportPopupHasBeenShown] != true && isLastpassInstalled
    self.hasDismissedAuthenticatorSunsetBanner =
      self.userSettings[.hasDismissedAuthenticatorSunsetBanner] ?? false

    combineSetup()
  }

  func onAppear() {
    updatePublisher.send({}())
  }

  private func combineSetup() {
    userSettings
      .settingsChangePublisher
      .combineLatest(premiumAnnouncementsViewModel.$announcements, updatePublisher)
      .map { $0.1 }
      .prepend(premiumAnnouncementsViewModel.announcements)
      .map { [weak self] announcements -> Banner? in
        guard let self = self else { return nil }
        if Authenticator.isOnDevice, !self.hasDismissedAuthenticatorSunsetBanner {
          return .authenticatorSunset
        }
        if self.shouldShowLastpassBanner, !announcements.isEmpty {
          return credentialsCount > 5 ? .premium : .lastpassImport
        }
        if !self.shouldShowLastpassBanner, !announcements.isEmpty {
          return .premium
        }
        if self.shouldShowLastpassBanner, announcements.isEmpty {
          return .lastpassImport
        }
        return nil
      }
      .assign(to: &$additionnalBanner)

    userSettings
      .settingsChangePublisher
      .sink { [weak self] key in
        guard let self = self else { return }
        switch key {
        case .hasDismissedAuthenticatorSunsetBanner:
          self.hasDismissedAuthenticatorSunsetBanner =
            self.userSettings[.hasDismissedAuthenticatorSunsetBanner] ?? false
        case .lastpassImportPopupHasBeenShown:
          self.shouldShowLastpassBanner =
            self.featureService.isEnabled(.lastpassImport)
            && self.userSettings[.lastpassImportPopupHasBeenShown] != true
            && self.isLastpassInstalled
        default:
          break
        }
      }.store(in: &subscriptions)
  }

  var hasPremiumAnnouncements: Bool {
    return !premiumAnnouncementsViewModel.announcements.isEmpty
  }
}

extension AutofillActivationStatus {
  public var showAutofillBanner: Bool {
    guard !Device.isMac else {
      return false
    }
    guard let isEnabled else {
      return true
    }
    return !isEnabled
  }
}

extension HomeTopBannerViewModel {
  public static var mock: HomeTopBannerViewModel {
    .init(
      autofillBannerViewModel: AutofillBannerViewModel.mock,
      authenticatorSunsetBannerViewModel: AuthenticatorSunsetBannerViewModel.mock,
      deeplinkingService: NotificationKitDeepLinkingServiceMock(),
      userSettings: .mock,
      featureService: .mock(),
      isLastpassInstalled: false,
      credentialsCount: 6,
      premiumFactory: .init { _ in .mock(announcements: [.premiumExpiredAnnouncement]) }
    )
  }
}
