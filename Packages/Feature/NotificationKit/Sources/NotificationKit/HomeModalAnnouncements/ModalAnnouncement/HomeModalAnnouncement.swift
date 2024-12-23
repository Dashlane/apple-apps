import BrazeKit
import Foundation

public enum HomeModalAnnouncementTrigger: CaseIterable {
  case sessionUnlocked
}

protocol HomeModalAnnouncement {
  var triggers: Set<HomeModalAnnouncementTrigger> { get }

  var announcement: HomeModalAnnouncementType? { get }
}

enum HomeModalAnnouncementType: Identifiable {

  case sheet(HomeSheetAnnouncement)
  case bottomSheet(HomeBottomSheetAnnouncement)
  case overScreen(HomeOverFullScreenAnnouncement)
  case alert(HomeAlertAnnouncement)

  var id: String {
    switch self {
    case .sheet(let sheet):
      return sheet.id
    case .bottomSheet(let sheet):
      return sheet.id
    case .overScreen(let over):
      return over.id
    case .alert(let alert):
      return alert.id
    }
  }
}

enum HomeSheetAnnouncement: Identifiable {
  case freeTrial(daysLeft: Int)
  case planRecommandation
  case autofillActivation

  var id: String {
    switch self {
    case .freeTrial(let daysLeft):
      return "freeTrial\(daysLeft)"
    case .planRecommandation:
      return "planRecommandation"
    case .autofillActivation:
      return "autofillActivation"
    }
  }
}

enum HomeBottomSheetAnnouncement: Identifiable {
  case braze(BrazeAnnouncement)

  var id: String {
    switch self {
    case .braze(let communication):
      return communication.id
    }
  }
}

enum HomeOverFullScreenAnnouncement: String, Identifiable {
  case rateApp

  var id: String { rawValue }
}

enum HomeAlertAnnouncement: String, Identifiable {
  case upgradeOperatingSystem

  var id: String { rawValue }
}
