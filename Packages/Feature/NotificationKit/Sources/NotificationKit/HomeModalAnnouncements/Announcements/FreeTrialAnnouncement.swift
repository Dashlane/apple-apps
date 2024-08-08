import CorePersonalData
import CorePremium
import CoreSettings
import DashTypes
import Foundation
import SwiftUI

public class FreeTrialAnnouncement: HomeModalAnnouncement, HomeAnnouncementsServicesInjecting {

  let triggers: Set<HomeModalAnnouncementTrigger> = [.sessionUnlocked]

  private let userSettings: UserSettings
  private let syncedSettings: SyncedSettingsService
  private let premiumStatusProvider: PremiumStatusProvider

  public init(
    userSettings: UserSettings,
    syncedSettings: SyncedSettingsService,
    premiumStatusProvider: PremiumStatusProvider
  ) {
    self.userSettings = userSettings
    self.syncedSettings = syncedSettings
    self.premiumStatusProvider = premiumStatusProvider
  }

  func shouldDisplay() -> Bool {
    let status = premiumStatusProvider.status
    guard status.b2bStatus?.statusCode != .inTeam else {
      return false
    }

    let b2cStatus = status.b2cStatus
    guard b2cStatus.statusCode == .subscribed, b2cStatus.isTrial else {
      return false
    }

    guard let accountCreationDate = syncedSettings[\.accountCreationDatetime],
      let numberOfDaysSinceAccountCreation = Date().numberOfDays(since: accountCreationDate),
      numberOfDaysSinceAccountCreation <= 1
    else {
      return false
    }

    if let trialStartedHasBeenShown: Bool = userSettings[.trialStartedHasBeenShown] {
      guard trialStartedHasBeenShown == false else {
        return false
      }
    }

    return true
  }

  var announcement: HomeModalAnnouncementType? {
    guard shouldDisplay() else { return nil }
    guard let daysLeft = premiumStatusProvider.status.b2cStatus.daysToExpiration() else {
      return nil
    }
    return .sheet(.freeTrial(daysLeft: daysLeft))
  }
}

extension FreeTrialAnnouncement {
  static var mock: FreeTrialAnnouncement {
    .init(
      userSettings: .mock,
      syncedSettings: .mock,
      premiumStatusProvider: .mock(status: .Mock.freeTrial))
  }
}
