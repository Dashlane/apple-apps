import Foundation
import CorePremium
import CorePersonalData
import CoreSettings
import DashlaneAppKit

struct TeamSpacesService {
    let businessInfo: BusinessTeamsInfo

    init(status: PremiumStatus?) {
        let businessTeams = status?.spaces.map { spaces in
            spaces.map { BusinessTeam(space: $0, anonymousTeamId: "") }
        }
        businessInfo = BusinessTeamsInfo(businessTeams: businessTeams ?? [])
    }
    
    func shouldDisplay(_ credential: Credential) -> Bool {
        return businessInfo.userSpace(forSpaceId: credential.spaceId) != nil
    }
}
