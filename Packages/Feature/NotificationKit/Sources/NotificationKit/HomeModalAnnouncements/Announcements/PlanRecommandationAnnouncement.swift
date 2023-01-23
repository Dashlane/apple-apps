import Foundation
import SwiftUI
import CoreSettings
import DashTypes
import CorePremium
import CorePersonalData

public class PlanRecommandationAnnouncement: HomeModalAnnouncement, HomeAnnouncementsServicesInjecting {

    let triggers: Set<HomeModalAnnouncementTrigger> = [.sessionUnlocked]

    private let userSettings: UserSettings
    private let syncedSettings: SyncedSettingsService
    private let premiumService: PremiumServiceProtocol
    private let planRecommandationService: PlanRecommandationService

    public init(userSettings: UserSettings,
                syncedSettings: SyncedSettingsService,
                premiumService: PremiumServiceProtocol) {
        self.userSettings = userSettings
        self.syncedSettings = syncedSettings
        self.premiumService = premiumService
        self.planRecommandationService = PlanRecommandationService(syncedSettings: syncedSettings, premiumService: premiumService)
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
    private let premiumService: PremiumServiceProtocol

    init(syncedSettings: SyncedSettingsService,
         premiumService: PremiumServiceProtocol) {
        self.syncedSettings = syncedSettings
        self.premiumService = premiumService
    }

    var isEligibleToPlanRecommandation: Bool {

                guard premiumService.status?.statusCode == .freeTrial else {
            return false
        }

        guard let numberOfDaysSinceAccountCreation = numberOfDaysAfterAccountCreation  else {
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
        .init(userSettings: .mock,
              syncedSettings: .mock,
              premiumService: PremiumServiceMock())
    }
}
