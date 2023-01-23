import Foundation
import Combine
import CoreUserTracking
import DashlaneAppKit
import DashTypes
import CorePremium

class UserSpaceSwitcherViewModel: UserSpacePopoverModelProtocol, SessionServicesInjecting {

    @Published
    var selectedSpace: UserSpace = .both

    @Published
    var availableSpaces: [UserSpace] = []

    @Published
    var isPopoverPresented: Bool = false

    let teamSpacesService: TeamSpacesService
    let activityReporter: ActivityReporterProtocol

    init(teamSpacesService: TeamSpacesService,
         activityReporter: ActivityReporterProtocol) {
        self.teamSpacesService = teamSpacesService
        self.activityReporter = activityReporter
        teamSpacesService.$availableSpaces.assign(to: &$availableSpaces)
        teamSpacesService.$selectedSpace.assign(to: &$selectedSpace)
    }

    func select(_ space: UserSpace) {
        teamSpacesService.selectedSpace = space
        activityReporter.report(UserEvent.SelectSpace(space: space.logItemSpace))
    }
}

extension UserSpaceSwitcherViewModel {
    static var mock: UserSpaceSwitcherViewModel {
        UserSpaceSwitcherViewModel(teamSpacesService: .mock(), activityReporter: .fake)
    }
}
