import Foundation
import SwiftUI
import CoreSettings
import DashTypes
import CorePremium
import CorePersonalData

public class FreeTrialAnnouncement: HomeModalAnnouncement, HomeAnnouncementsServicesInjecting {

    let triggers: Set<HomeModalAnnouncementTrigger> = [.sessionUnlocked]

    private let userSettings: UserSettings
    private let syncedSettings: SyncedSettingsService
    private let premiumService: PremiumServiceProtocol

    public init(userSettings: UserSettings,
                syncedSettings: SyncedSettingsService,
                premiumService: PremiumServiceProtocol) {
        self.userSettings = userSettings
        self.syncedSettings = syncedSettings
        self.premiumService = premiumService
        
    }
    
    func shouldDisplay() -> Bool {
                guard premiumService.status?.statusCode == .freeTrial else {
            return false
        }

                guard let accountCreationDate = syncedSettings[\.accountCreationDatetime], let numberOfDaysSinceAccountCreation = Date().numberOfDays(since: accountCreationDate), numberOfDaysSinceAccountCreation <= 1 else {
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
        return .sheet(.freeTrial)
    }
}

extension FreeTrialAnnouncement {
    static var mock: FreeTrialAnnouncement {
        .init(userSettings: .mock,
              syncedSettings: .mock,
              premiumService: PremiumServiceMock())
    }
}
