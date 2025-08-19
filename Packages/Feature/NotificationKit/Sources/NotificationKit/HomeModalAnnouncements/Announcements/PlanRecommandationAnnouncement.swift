import CorePersonalData
import CorePremium
import CoreSettings
import CoreTypes
import Foundation
import SwiftUI

public class PlanRecommandationAnnouncement: HomeModalAnnouncement,
  HomeAnnouncementsServicesInjecting
{

  let triggers: Set<HomeModalAnnouncementTrigger> = [.sessionUnlocked]

  private let userSettings: UserSettings
  private let syncedSettings: SyncedSettingsService
  private let planRecommandationService: PlanRecommandationService

  public init(
    userSettings: UserSettings,
    syncedSettings: SyncedSettingsService,
    premiumStatusProvider: PremiumStatusProvider
  ) {
    self.userSettings = userSettings
    self.syncedSettings = syncedSettings
    self.planRecommandationService = PlanRecommandationService(
      syncedSettings: syncedSettings, premiumStatusProvider: premiumStatusProvider)
  }

  func shouldDisplay() -> Bool {
    if let planRecommandationHasBeenShown: Bool = userSettings[.planRecommandationHasBeenShown] {
      guard planRecommandationHasBeenShown == false else {
        return false
      }
    }

    return planRecommandationService.isEligibleToPlanRecommandation
  }

  var announcement: HomeModalAnnouncementType? {
    guard shouldDisplay() else { return nil }
    return .sheet(.planRecommandation)
  }
}

private class PlanRecommandationService {
  private let syncedSettings: SyncedSettingsService
  private let premiumStatusProvider: PremiumStatusProvider

  init(
    syncedSettings: SyncedSettingsService,
    premiumStatusProvider: PremiumStatusProvider
  ) {
    self.syncedSettings = syncedSettings
    self.premiumStatusProvider = premiumStatusProvider
  }

  var isEligibleToPlanRecommandation: Bool {
    let status = premiumStatusProvider.status
    guard status.b2bStatus?.statusCode != .inTeam,
      status.b2cStatus.statusCode == .subscribed && status.b2cStatus.isTrial
    else {
      return false
    }

    guard let numberOfDaysSinceAccountCreation = numberOfDaysAfterAccountCreation else {
      return false
    }

    return numberOfDaysSinceAccountCreation >= 16
  }

  private var numberOfDaysAfterAccountCreation: Int? {
    guard let accountCreationDate = syncedSettings[\.accountCreationDatetime] else {
      return nil
    }
    return Date().numberOfDays(since: accountCreationDate)
  }
}

extension PlanRecommandationAnnouncement {
  static var mock: PlanRecommandationAnnouncement {
    .init(
      userSettings: .mock,
      syncedSettings: .mock,
      premiumStatusProvider: .mock(status: .Mock.free))
  }
}
