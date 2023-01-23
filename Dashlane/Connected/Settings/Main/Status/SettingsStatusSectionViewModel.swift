import SwiftUI
import DashlaneAppKit
import CorePremium

@MainActor
class SettingsStatusSectionViewModel: ObservableObject, SessionServicesInjecting {
    @Published
    var status: PremiumStatus?

    @Published
    var businessTeam: BusinessTeam?

    let premiumService: PremiumServiceProtocol
    let deepLinkingService: DeepLinkingServiceProtocol
    init(premiumService: PremiumServiceProtocol,
         teamSpacesService: TeamSpacesServiceProtocol,
         deepLinkingService: DeepLinkingServiceProtocol) {
        self.premiumService = premiumService
        self.deepLinkingService = deepLinkingService
        premiumService.premiumStatusPublisher.assign(to: &$status)
        teamSpacesService.businessTeamsInfoPublisher.map(\.availableBusinessTeam).assign(to: &$businessTeam)
    }

    func showPurchase() {
        deepLinkingService.handleLink(.planPurchase(initialView: .list))
    }

}

extension SettingsStatusSectionViewModel {
    static var mock: SettingsStatusSectionViewModel {
        .init(premiumService: PremiumServiceMock(),
              teamSpacesService: TeamSpacesServiceMock(),
              deepLinkingService: DeepLinkingService.fakeService)
    }
}
