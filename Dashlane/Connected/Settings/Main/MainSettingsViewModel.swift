import Foundation
import SwiftUI
import Combine
import CoreSession
import CorePremium
import DashTypes
import DashlaneAppKit
import CoreSettings
import CoreNetworking
import DashlaneReportKit
import UIDelight
import CoreFeature
import NotificationKit

final class MainSettingsViewModel: ObservableObject, SessionServicesInjecting {

    let session: Session
    private let premiumService: PremiumServiceProtocol
    private let teamSpacesService: TeamSpacesService
    private let deepLinkingService: DeepLinkingServiceProtocol
    private let lockService: LockServiceProtocol
    private let usageLogService: UsageLogServiceProtocol
    private let sharingLinkService: SharingLinkServiceProtocol
    let userSettings: UserSettings
    private let labsService: LabsService
    let featureService: FeatureServiceProtocol

    let deepLinkPublisher: AnyPublisher<SettingsDeepLinkComponent, Never>

    let settingsStatusSectionViewModelFactory: SettingsStatusSectionViewModel.Factory

    init(session: Session,
         premiumService: PremiumServiceProtocol,
         teamSpacesService: TeamSpacesService,
         deepLinkingService: DeepLinkingServiceProtocol,
         lockService: LockServiceProtocol,
         usageLogService: UsageLogServiceProtocol,
         sharingLinkService: SharingLinkServiceProtocol,
         userSettings: UserSettings,
         labsService: LabsService,
         featureService: FeatureServiceProtocol,
         settingsStatusSectionViewModelFactory: SettingsStatusSectionViewModel.Factory) {
        self.session = session
        self.premiumService = premiumService
        self.teamSpacesService = teamSpacesService
        self.deepLinkingService = deepLinkingService
        self.lockService = lockService
        self.usageLogService = usageLogService
        self.sharingLinkService = sharingLinkService
        self.userSettings = userSettings
        self.labsService = labsService
        self.featureService = featureService
        self.settingsStatusSectionViewModelFactory = settingsStatusSectionViewModelFactory
        deepLinkPublisher = deepLinkingService.settingsComponentPublisher()
    }

    @Published
    var activityItem: ActivityItem?

    func lock() {
        lockService.locker.screenLocker?.secureLock()
    }

    var login: Login {
        session.login
    }

        func inviteFriends() {
        sharingLinkService.getSharingLink(forEmail: session.login.email) { [weak self] sharingID in
            guard let sharingID = sharingID else { return }

            let url =  "_\(System.language)/im/\(sharingID)"

            let inviteText = L10n.Localizable.kwInviteEmailBody(url)
            self?.usageLogService.post(UsageLogCode75GeneralActions(type: "invite", action: "open"))

            DispatchQueue.main.async {
                self?.activityItem = ActivityItem(items: inviteText)
            }
        }
    }

        var shouldDisplayLabs: Bool {
        labsService.isLabsAvailable && featureService.isEnabled(.labs)
    }

        static func mock() -> MainSettingsViewModel {
        return MainSettingsViewModel(session: Session.mock,
                                     premiumService: PremiumServiceMock(),
                                     teamSpacesService: .mock(),
                                     deepLinkingService: DeepLinkingService.fakeService,
                                     lockService: LockServiceMock(),
                                     usageLogService: UsageLogService.fakeService,
                                     sharingLinkService: SharingLinkService.mock,
                                     userSettings: UserSettings(internalStore: InMemoryLocalSettingsStore()),
                                     labsService: LabsService(),
                                     featureService: .mock(),
                                     settingsStatusSectionViewModelFactory: .init({ .mock }))
    }
}

extension PremiumServiceProtocol {
    public var shouldDisplayRenewSoon: Bool {
        guard isPremium,
            status?.statusCode != .freeTrial,
            let premiumStatus = status,
            let endDate = premiumStatus.endDate,
            premiumStatus.autoRenewal == false,
            let remainingDays = Calendar.current.dateComponents([Calendar.Component.day], from: Date(), to: endDate).day
            else { return false }

        return remainingDays < 30
    }
}
