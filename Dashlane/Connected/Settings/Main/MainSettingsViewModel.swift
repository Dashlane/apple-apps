import Foundation
import SwiftUI
import Combine
import CoreSession
import CorePremium
import DashTypes
import DashlaneAppKit
import CoreSettings
import CoreNetworking
import UIDelight
import CoreFeature
import NotificationKit
import LoginKit

@MainActor
final class MainSettingsViewModel: ObservableObject, SessionServicesInjecting {

    let session: Session

    let settingsStatusSectionViewModelFactory: SettingsStatusSectionViewModel.Factory
	let addNewDeviceFactory: AddNewDeviceViewModel.Factory

        let userSettings: UserSettings
    private let sessionCryptoEngineProvider: CryptoEngineProvider
    private let premiumService: PremiumServiceProtocol
    private let teamSpacesService: TeamSpacesService
    private let lockService: LockServiceProtocol
    private let sharingLinkService: SharingLinkServiceProtocol
    private let labsService: LabsService
    private let featureService: FeatureServiceProtocol
    private let userApiClient: UserDeviceAPIClient

    init(session: Session,
         sessionCryptoEngineProvider: SessionCryptoEngineProvider,
         premiumService: PremiumServiceProtocol,
         teamSpacesService: TeamSpacesService,
         lockService: LockServiceProtocol,
         sharingLinkService: SharingLinkServiceProtocol,
         userSettings: UserSettings,
         labsService: LabsService,
         featureService: FeatureServiceProtocol,
         userApiClient: UserDeviceAPIClient,
         settingsStatusSectionViewModelFactory: SettingsStatusSectionViewModel.Factory,
         addNewDeviceFactory: AddNewDeviceViewModel.Factory) {
        self.session = session
        self.premiumService = premiumService
        self.teamSpacesService = teamSpacesService
        self.lockService = lockService
        self.sharingLinkService = sharingLinkService
        self.userSettings = userSettings
        self.labsService = labsService
        self.featureService = featureService
        self.settingsStatusSectionViewModelFactory = settingsStatusSectionViewModelFactory
        self.userApiClient = userApiClient
        self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
		self.addNewDeviceFactory = addNewDeviceFactory
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

            DispatchQueue.main.async {
                self?.activityItem = ActivityItem(items: inviteText)
            }
        }
    }

        var shouldDisplayLabs: Bool {
        labsService.isLabsAvailable && featureService.isEnabled(.labs)
    }

    func makeAddNewDeviceViewModel() -> AddNewDeviceViewModel {
        return addNewDeviceFactory.make()
    }

        static func mock() -> MainSettingsViewModel {
        return MainSettingsViewModel(session: Session.mock,
                                     sessionCryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()),
                                     premiumService: PremiumServiceMock(),
                                     teamSpacesService: .mock(),
                                     lockService: LockServiceMock(),
                                     sharingLinkService: SharingLinkService.mock,
                                     userSettings: UserSettings(internalStore: .mock()),
                                     labsService: LabsService(),
                                     featureService: .mock(),
                                     userApiClient: UserDeviceAPIClient.fake,
									 settingsStatusSectionViewModelFactory: .init({ .mock }), addNewDeviceFactory: .init({_ in .mock }))
    }
}
