import Foundation
import CorePremium
import DashTypes

struct FetchSpacesInfoHandler: MaverickOrderHandleable, SessionServicesInjecting {

    typealias Request = MaverickEmptyRequest

    struct Response: MaverickOrderResponse {
        let id: String
        let spaces: [MaverickSpace]
    }

    struct MaverickSpace: Encodable {

        struct Settings: Encodable {
            let enableForcedCategorization: Bool
            let spaceForcedDomains: [String]
        }

        let spaceId: String
        let isSSOUser: Bool
        let displayName: String
        let letter: String
        let color: String
        let settings: Settings

        static var `default`: MaverickSpace {
            self.init(spaceId: "",
                      isSSOUser: false,
                      displayName: "",
                      letter: "",
                      color: "",
                      settings: .init(enableForcedCategorization: false,
                                      spaceForcedDomains: []))
        }
    }

    let maverickOrderMessage: MaverickOrderMessage
    let premiumService: PremiumService
    
    init(maverickOrderMessage: MaverickOrderMessage, premiumService: PremiumService) {
        self.maverickOrderMessage = maverickOrderMessage
        self.premiumService = premiumService
    }
    
    func performOrder() throws -> Response? {
        var spacesToSend = premiumService.status?.spaces?.compactMap(MaverickSpace.init) ?? []

        if spacesToSend.isEmpty {
                        spacesToSend.append(.default)
        } else {
            spacesToSend.append(MaverickSpace(space: .personal))
        }

        return Response(id: actionMessageID,
                        spaces: spacesToSend)

    }
}

extension FetchSpacesInfoHandler.MaverickSpace {
    init(space: Space) {
        self.spaceId = space.teamId
        self.isSSOUser = space.isSSOUser ?? false
        self.displayName = space.teamName ?? L10n.Localizable.teamSpacesPersonalSpaceName
        self.letter = space.letter
        let domains: [String]
        if let forcedDomainsEnabled = space.info.forcedDomainsEnabled, forcedDomainsEnabled,
           let teamDomains = space.info.teamDomains {
            domains = teamDomains
        } else {
            domains = []
        }
        self.color = space.color
        self.settings = Settings(enableForcedCategorization: false,
                                 spaceForcedDomains: domains)
    }
}
