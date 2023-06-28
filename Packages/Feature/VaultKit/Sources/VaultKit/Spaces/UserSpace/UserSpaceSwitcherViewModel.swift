import Foundation
import Combine
import CoreUserTracking
import DashTypes
import CorePremium

public class UserSpaceSwitcherViewModel: UserSpacePopoverModelProtocol, VaultKitServicesInjecting {

    @Published
    public var selectedSpace: UserSpace = .both

    @Published
    public var availableSpaces: [UserSpace] = []

    @Published
    public var isPopoverPresented: Bool = false

    var teamSpacesService: CorePremium.TeamSpacesServiceProtocol
    let activityReporter: ActivityReporterProtocol

    public init(
        teamSpacesService: CorePremium.TeamSpacesServiceProtocol,
        activityReporter: ActivityReporterProtocol
    ) {
        self.teamSpacesService = teamSpacesService
        self.activityReporter = activityReporter
        teamSpacesService.availableSpacesPublisher.assign(to: &$availableSpaces)
        teamSpacesService.selectedSpacePublisher.assign(to: &$selectedSpace)
    }

    public func select(_ space: UserSpace) {
        teamSpacesService.selectedSpace = space
        activityReporter.report(UserEvent.SelectSpace(space: space.logItemSpace))
    }
}

public extension UserSpaceSwitcherViewModel {
    static var mock: UserSpaceSwitcherViewModel {
        UserSpaceSwitcherViewModel(teamSpacesService: .mock(), activityReporter: .fake)
    }
}
