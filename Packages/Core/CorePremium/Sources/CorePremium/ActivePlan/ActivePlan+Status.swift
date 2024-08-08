import DashlaneAPI
import Foundation

extension ActivePlan {
  public init(status: UserDeviceAPIClient.Premium.GetPremiumStatus.Response.B2cStatus) {
    switch status.statusCode {
    case .free:
      self = .free
    case .legacy:
      self = .legacy
    case .subscribed:
      guard !status.isTrial else {
        self = .trial
        return
      }

      switch status.planFeature {
      case .premium where status.isPremiumFreeForLife():
        self = .premium(.freeForLife)
      case .premium where status.isPremiumFreeOfCharge:
        self = .premium(.freeOfCharge)
      case .premium:
        if let familyStatus = status.familyStatus {
          self = .premiumFamily(isAdmin: familyStatus.isAdmin)
        } else {
          self = .premium(.standard)
        }
      case .premiumplus:
        if let familyStatus = status.familyStatus {
          self = .premiumPlusFamily(isAdmin: familyStatus.isAdmin)
        } else {
          self = .premiumPlus
        }
      case .essentials:
        self = .advanced
      case .backupForAll:
        self = .legacy
      case .none:
        self = .premium(.standard)
      case .undecodable:
        self = .free
      }
    case .undecodable:
      self = .free
    }
  }
}

extension UserDeviceAPIClient.Premium.GetPremiumStatus.Response.B2cStatus {
  public var humanReadableActivePlan: ActivePlan {
    .init(status: self)
  }
}

extension UserDeviceAPIClient.Premium.GetPremiumStatus.Response.B2cStatus {
  var isPremiumFreeOfCharge: Bool {
    return statusCode == .subscribed && hasPaid == false
  }

  func isPremiumFreeForLife() -> Bool {
    guard statusCode == .subscribed, let years = yearsToExpiration() else {
      return false
    }

    return years > 65
  }

  public func daysToExpiration() -> Int? {
    guard let endDateUnix = endDateUnix else {
      return nil
    }

    return Calendar.current.dateComponents(
      [.day], toStartOfTheDayOf: Date(timeIntervalSince1970: TimeInterval(endDateUnix))
    ).day
  }

  func yearsToExpiration() -> Int? {
    guard let endDateUnix = endDateUnix else {
      return nil
    }

    return Calendar.current.dateComponents(
      [.year], toStartOfTheDayOf: Date(timeIntervalSince1970: TimeInterval(endDateUnix))
    ).year
  }
}

extension Status.B2cStatus.PlanFeature {
  static var advanced: Self {
    return .essentials
  }
}

extension Status.B2cStatus.PreviousPlan {
  public func daysSinceExpiration() -> Int {
    return
      -(Calendar.current.dateComponents(
        [.day], toStartOfTheDayOf: Date(timeIntervalSince1970: TimeInterval(endDateUnix))
      ).day ?? 0)
  }
}

extension Calendar {
  func dateComponents(_ components: Set<Calendar.Component>, toStartOfTheDayOf end: Date)
    -> DateComponents
  {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let endDateUpdated = calendar.startOfDay(for: end)
    return calendar.dateComponents(components, from: today, to: endDateUpdated)
  }
}
