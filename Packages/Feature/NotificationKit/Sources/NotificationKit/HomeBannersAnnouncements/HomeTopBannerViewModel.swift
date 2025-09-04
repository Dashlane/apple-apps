import Combine
import CoreFeature
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import SwiftTreats

@MainActor
public class HomeTopBannerViewModel: ObservableObject, HomeAnnouncementsServicesInjecting {
  enum Banner {
    case frozen
    case premium
    case lastpassImport
  }

  @Published var additionnalBanner: Banner?
  @Published var shouldShowLastpassBanner: Bool

  let premiumAnnouncementsViewModel: PremiumAnnouncementsViewModel
  let autofillBannerViewModel: AutofillBannerViewModel
  let frozenBannerViewModel: FrozenBannerViewModel
  let lastpassImportBannerViewModel: LastpassImportBannerViewModel
  private let credentialsCount: Int
  private let userSettings: UserSettings
  private let featureService: FeatureServiceProtocol
  private let vaultStateService: VaultStateServiceProtocol
  private let isLastpassInstalled: Bool

  private var shouldShowPremiumBannerView: Bool {
    hasPremiumAnnouncements
  }

  private let updatePublisher = PassthroughSubject<Void, Never>()
  private var subscriptions: Set<AnyCancellable> = .init()

  public init(
    autofillBannerViewModel: AutofillBannerViewModel,
    deeplinkingService: NotificationKitDeepLinkingServiceProtocol,
    userSettings: UserSettings,
    featureService: FeatureServiceProtocol,
    vaultStateService: VaultStateServiceProtocol,
    isLastpassInstalled: Bool,
    credentialsCount: Int,
    premiumFactory: PremiumAnnouncementsViewModel.Factory
  ) {
    self.autofillBannerViewModel = autofillBannerViewModel
    self.userSettings = userSettings
    self.featureService = featureService
    self.vaultStateService = vaultStateService
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

    combineSetup()
  }

  func onAppear() {
    updatePublisher.send({}())
  }

  private func combineSetup() {
    let userSettingsChangeTrigger = userSettings
      .settingsChangePublisher
      .mapToVoid()
      .prepend(Void())

    let updatePublisherTrigger =
      updatePublisher
      .prepend(Void())

    premiumAnnouncementsViewModel.$announcements
      .combineLatest(
        userSettingsChangeTrigger, updatePublisherTrigger, vaultStateService.vaultStatePublisher()
      )
      .map { (premiumAnnouncements: $0.0, vaultState: $0.3) }
      .map { [weak self] (premiumAnnouncements, vaultState) -> Banner? in
        guard let self = self else { return nil }
        if vaultState == .frozen {
          return .frozen
        }
        if self.shouldShowLastpassBanner, !premiumAnnouncements.isEmpty {
          return credentialsCount > 5 ? .premium : .lastpassImport
        }
        if !self.shouldShowLastpassBanner, !premiumAnnouncements.isEmpty {
          return .premium
        }
        if self.shouldShowLastpassBanner, premiumAnnouncements.isEmpty {
          return .lastpassImport
        }
        return nil
      }
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .assign(to: &$additionnalBanner)

    userSettings
      .settingsChangePublisher
      .sink { [weak self] key in
        guard let self = self else { return }
        switch key {
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
    guard !Device.is(.mac) else {
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
      deeplinkingService: NotificationKitDeepLinkingServiceMock(),
      userSettings: .mock,
      featureService: .mock(),
      vaultStateService: .mock(),
      isLastpassInstalled: false,
      credentialsCount: 6,
      premiumFactory: .init { _ in .mock(announcements: [.premiumExpiredAnnouncement]) }
    )
  }
}
