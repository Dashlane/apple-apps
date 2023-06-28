import Foundation
import Combine
import DashTypes
import CorePremium
import SwiftTreats
import UIKit
import CoreSettings
import CoreFeature
import CoreLocalization

public enum PremiumAnnouncement: Int {
    case autorenewalFailedAnnouncement
    case specialOfferAnnouncement
    case premiumExpiredAnnouncement
    case premiumWillExpireAnnouncement
}

public class PremiumAnnouncementsViewModel: ObservableObject {

    let premiumService: PremiumServiceProtocol
    let teamspaceService: TeamSpacesServiceProtocol
    let featureService: FeatureServiceProtocol
    @Published
    public var announcements: [PremiumAnnouncement] = []
    private var subscriptions = Set<AnyCancellable>()
    let deeplinkService: NotificationKitDeepLinkingServiceProtocol
    let userSettings: UserSettings
    private var excludedAnnouncements: Set<PremiumAnnouncement>

    var premiumWillExpireTitle: String {
        if premiumService.daysToExpiration == 1 {
            return L10n.Core.announcePremiumExpiring1DayBody
        } else {
            return L10n.Core.announcePremiumExpiringNDaysBody(premiumService.daysToExpiration)
        }
    }

    public init(premiumService: PremiumServiceProtocol,
                teamspaceService: TeamSpacesServiceProtocol,
                featureService: FeatureServiceProtocol,
                deeplinkService: NotificationKitDeepLinkingServiceProtocol,
                userSettings: UserSettings,
                excludedAnnouncements: Set<PremiumAnnouncement> = []) {
        self.premiumService = premiumService
        self.featureService = featureService
        self.teamspaceService = teamspaceService
        self.deeplinkService = deeplinkService
        self.userSettings = userSettings
        self.excludedAnnouncements = excludedAnnouncements
        setup()
    }

    func setup() {
        premiumService
            .statusPublisher
            .combineLatest(teamspaceService.availableSpacesPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status, availableSpaces in
                                guard let self = self, availableSpaces.count < 2 else {
                    return
                }
                                guard status?.statusCode != .legacy else {
                    return
                }
                                if let familyInformation = status?.familyMembership?.first {
                    guard familyInformation.isAdmin else {
                        return
                    }
                }
                self.setupPremiumWillExpireAnnouncement()
                self.setupPremiumExpiredAnnouncement()
                self.setupAutoRenewalFailedAnnouncement(status: status)
            }
            .store(in: &subscriptions)

        premiumService.hasDiscountOffersPublisher.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let self = self else { return }
            if value {
                self.addAnnouncement(.specialOfferAnnouncement)
            } else {
                self.removeAnnouncement(.specialOfferAnnouncement)
            }
        }.store(in: &subscriptions)
    }

    func setupPremiumWillExpireAnnouncement() {
        guard !premiumService.isAutoRenewing,
              !premiumService.isExpired,
              premiumService.daysToExpiration <= 30 else {
                removeAnnouncement(.premiumWillExpireAnnouncement)
                return
        }
        addAnnouncement(.premiumWillExpireAnnouncement)
    }

    func setupPremiumExpiredAnnouncement() {
        guard premiumService.isExpired,
            premiumService.isExpiredRecently else {
                removeAnnouncement(.premiumExpiredAnnouncement)
                return
        }
        addAnnouncement(.premiumExpiredAnnouncement)
    }

    private func setupAutoRenewalFailedAnnouncement(status: PremiumStatus?) {
        guard !featureService.isEnabled(.disableAutorenewalAnnouncement),
              let status = status,
              status.autoRenewalFailed == true,
              status.planType == "ios_renewable" else {
                  removeAnnouncement(.autorenewalFailedAnnouncement)
                  return
              }
        addAnnouncement(.autorenewalFailedAnnouncement)
    }

    private func addAnnouncement(_ announcement: PremiumAnnouncement) {
        guard !excludedAnnouncements.contains(announcement) else {
            return
        }
        announcements = Set(announcements + [announcement]).sorted(by: { $0.rawValue < $1.rawValue })
    }

    func showSettings() {
        deeplinkService.handle(.goToSettings(.root))
    }

    func showSystemSettings() {
        let url: URL
        if Device.isMac {
            url = URL(fileURLWithPath: "/System/Library/PreferencePanes/SoftwareUpdate.prefPane")
        } else {
            url = URL(string: "App-prefs:root=General")!
        }
        UIApplication.shared.open(url)
    }

    func showPremium(capability: CapabilityKey? = nil) {
        guard let capability = capability else {
            deeplinkService.handle(.goToPremium)
            return
        }
        deeplinkService.handle(.displayPaywall(capability))
    }

    func removeAnnouncement(_ announcement: PremiumAnnouncement) {
        announcements = announcements.filter { $0 != announcement }
    }

    func openAppleUpdatePaymentsPage() {
        let url = URL(string: "_")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

public extension PremiumAnnouncementsViewModel {

    static func mock(announcements: [PremiumAnnouncement]) -> PremiumAnnouncementsViewModel {
        let model = PremiumAnnouncementsViewModel(premiumService: PremiumServiceMock(),
                                                  teamspaceService: .mock(),
                                                  featureService: .mock(),
                                                  deeplinkService: NotificationKitDeepLinkingServiceMock(),
                                                  userSettings: UserSettings.mock,
                                                  excludedAnnouncements: [])
        model.announcements = announcements
        return model
    }
}
