import Foundation
import CorePremium

extension Space {
    var maverickDictionary: [String: Any] {
        [
            "spaceId": teamId,
            "color": color,
            "letter": letter
        ]
    }
    
    static var personal: Space {
        .init(teamId: "",
              letter: "P",
              color: "#d000af",
              associatedEmail: "",
              membersNumber: 0,
              teamAdmins: [],
              billingAdmins: [],
              isTeamAdmin: false,
              isBillingAdmin: false,
              isSSOUser: false,
              planType: "",
              status: .accepted,
              info: SpaceInfo())
    }
}
