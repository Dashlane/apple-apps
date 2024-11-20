import Combine
import CoreFeature
import CoreSettings
import DashTypes
import Foundation

public class AutofillActivationModalAnnouncement: HomeModalAnnouncement,
  HomeAnnouncementsServicesInjecting
{

  private let userSettings: UserSettings
  let identifier: String = UUID().uuidString

  let triggers: Set<HomeModalAnnouncementTrigger> = [.sessionUnlocked]
  private let featureService: FeatureServiceProtocol

  private var activationStatus: AutofillActivationStatus = .unknown
  private var subscriptions: Set<AnyCancellable> = []

  var announcement: HomeModalAnnouncementType? {
    guard shouldDisplay() else { return nil }
    return .sheet(.autofillActivation)
  }

  public init(
    userSettings: UserSettings,
    autofillService: NotificationKitAutofillServiceProtocol,
    featureService: FeatureServiceProtocol
  ) {
    self.userSettings = userSettings
    self.featureService = featureService

    autofillService.notificationKitActivationStatus.sink { [weak self] status in
      self?.activationStatus = status
    }
    .store(in: &subscriptions)
  }

  func shouldDisplay() -> Bool {
    let autofillActivationPopUpHasBeenShown: Bool =
      userSettings[.autofillActivationPopUpHasBeenShown] ?? false
    guard autofillActivationPopUpHasBeenShown == false else {
      return false
    }

    guard activationStatus == .disabled else {
      return false
    }

    let hasUserDismissedOnboardingChecklist: Bool =
      userSettings[.hasUserDismissedOnboardingChecklist] ?? false
    let hasUserUnlockedOnboardingChecklist: Bool =
      userSettings[.hasUserUnlockedOnboardingChecklist] ?? false
    guard hasUserDismissedOnboardingChecklist && hasUserUnlockedOnboardingChecklist else {
      return false
    }

    return true
  }
}

extension AutofillActivationModalAnnouncement {
  static var mock: AutofillActivationModalAnnouncement {
    .init(
      userSettings: .mock, autofillService: FakeNotificationKitAutofillService(),
      featureService: .mock())
  }
}
