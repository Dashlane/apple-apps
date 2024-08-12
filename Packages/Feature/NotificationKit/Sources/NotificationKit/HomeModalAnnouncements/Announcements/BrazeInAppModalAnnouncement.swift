import Foundation

public class BrazeInAppModalAnnouncement: HomeModalAnnouncement, HomeAnnouncementsServicesInjecting
{

  let identifier: String = UUID().uuidString

  private(set) var brazeAnnouncement: BrazeAnnouncement?

  let triggers: Set<HomeModalAnnouncementTrigger> = [.sessionUnlocked]

  public init(brazeService: BrazeServiceProtocol) {
    self.brazeAnnouncement = brazeService.modals.first
  }

  var announcement: HomeModalAnnouncementType? {
    guard let brazeAnnouncement else { return nil }
    return .bottomSheet(.braze(brazeAnnouncement))
  }
}

extension BrazeInAppModalAnnouncement {
  static var mock: BrazeInAppModalAnnouncement {
    .init(brazeService: BrazeServiceMock())
  }
}
