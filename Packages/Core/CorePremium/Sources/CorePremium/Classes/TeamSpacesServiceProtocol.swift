import Foundation
import Combine

public protocol TeamSpacesServiceProtocol {
    var availableSpacesPublisher: Published<[UserSpace]>.Publisher { get }
    var businessTeamsInfo: BusinessTeamsInfo { get }
    var businessTeamsInfoPublisher: Published<BusinessTeamsInfo>.Publisher { get }
    var isSSOUser: Bool { get }
    var is2FAEnforced: Bool { get }
}


public extension TeamSpacesServiceProtocol {
    var isSSOUser: Bool {
        return businessTeamsInfo.availableBusinessTeam?.space.isSSOUser ?? false
    }
    
    var is2FAEnforced: Bool {
        guard let status = businessTeamsInfo.availableBusinessTeam?.space.info.twoFAEnforced,
              status != .disabled else {
                        return false
        }
        return true
    }
}

public class TeamSpacesServiceMock: TeamSpacesServiceProtocol {

    @Published
    var availableSpaces = [UserSpace]()

    public var availableSpacesPublisher: Published<[UserSpace]>.Publisher {
        $availableSpaces
    }

    @Published
    public var businessTeamsInfo: BusinessTeamsInfo = BusinessTeamsInfo(businessTeams: [])

    public var businessTeamsInfoPublisher: Published<BusinessTeamsInfo>.Publisher {
        $businessTeamsInfo
    }

    public var isSSOUser: Bool = false
    public var is2FAEnforced: Bool = false

    public init() {
        
    }
}
