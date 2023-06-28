import Foundation
import Combine

public protocol TeamSpacesServiceProtocol {
    var availableSpaces: [UserSpace] { get }
    var availableSpacesPublisher: Published<[UserSpace]>.Publisher { get }
    var businessTeamsInfo: BusinessTeamsInfo { get }
    var businessTeamsInfoPublisher: Published<BusinessTeamsInfo>.Publisher { get }
    var isSSOUser: Bool { get }
    var is2FAEnforced: Bool { get }
    var selectedSpacePublisher: Published<UserSpace>.Publisher { get }
    var selectedSpace: UserSpace { get set }
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

public extension TeamSpacesServiceProtocol where Self == TeamSpacesServiceMock {
    static func mock(selectedSpace: UserSpace = .both,
                     availableSpaces: [UserSpace] = [],
                     isSSOUser: Bool = false,
                     is2FAEnforced: Bool = false) -> TeamSpacesServiceMock {
        return .init(selectedSpace: selectedSpace,
                     availableSpaces: availableSpaces,
                     isSSOUser: isSSOUser,
                     is2FAEnforced: is2FAEnforced)
    }
}

public class TeamSpacesServiceMock: TeamSpacesServiceProtocol {

    @Published
    public var selectedSpace: UserSpace

    public var selectedSpacePublisher: Published<UserSpace>.Publisher {
        $selectedSpace
    }

    @Published
    public var availableSpaces: [UserSpace]

    public var availableSpacesPublisher: Published<[UserSpace]>.Publisher {
        $availableSpaces
    }

    @Published
    public var businessTeamsInfo: BusinessTeamsInfo = BusinessTeamsInfo(businessTeams: [])

    public var businessTeamsInfoPublisher: Published<BusinessTeamsInfo>.Publisher {
        $businessTeamsInfo
    }

    public var isSSOUser: Bool
    public var is2FAEnforced: Bool

    public init(selectedSpace: UserSpace,
                availableSpaces: [UserSpace],
                isSSOUser: Bool,
                is2FAEnforced: Bool) {
        self.selectedSpace = selectedSpace
        self.availableSpaces = availableSpaces
        self.isSSOUser = isSSOUser
        self.is2FAEnforced = is2FAEnforced

    }
}
