import CorePremium
import CoreSettings
import DashTypes
import Foundation

public struct HomeModalAnnouncementsScheduler: HomeAnnouncementsServicesInjecting {

  let announcements: [HomeModalAnnouncement]

  public init(
    brazeInAppModalAnnouncementFactory: BrazeInAppModalAnnouncement.Factory,
    rateAppModalAnnouncement: RateAppModalAnnouncement.Factory,
    freeTrialAnnouncement: FreeTrialAnnouncement.Factory,
    planRecommandationAnnouncement: PlanRecommandationAnnouncement.Factory,
    autofillActivationAnnouncement: AutofillActivationModalAnnouncement.Factory,
    updateOperatingSystemAnnouncement: UpdateOperatingSystemAnnouncement.Factory
  ) {

    self.announcements = [
      brazeInAppModalAnnouncementFactory.make(),
      updateOperatingSystemAnnouncement.make(),
      rateAppModalAnnouncement.make(),
      freeTrialAnnouncement.make(),
      planRecommandationAnnouncement.make(),
      autofillActivationAnnouncement.make(),
    ]
  }

  func evaluate(for trigger: HomeModalAnnouncementTrigger) -> HomeModalAnnouncementType? {
    announcements
      .filter({ $0.triggers.contains(trigger) })
      .compactMap({ $0.announcement })
      .first
  }

}
