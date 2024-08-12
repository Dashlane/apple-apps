import Combine
import CorePremium
import CoreUserTracking
import DashTypes
import Foundation

@MainActor
public class UserSpaceSwitcherViewModel: UserSpacePopoverModelProtocol, VaultKitServicesInjecting {

  @Published
  public var configuration: UserSpacesService.SpacesConfiguration

  public var availableSpaces: [UserSpace] {
    configuration.availableSpaces
  }

  public var selectedSpace: UserSpace {
    configuration.selectedSpace
  }

  @Published
  public var isPopoverPresented: Bool = false

  var userSpacesService: UserSpacesService
  let activityReporter: ActivityReporterProtocol

  public init(
    userSpacesService: UserSpacesService,
    activityReporter: ActivityReporterProtocol
  ) {
    self.userSpacesService = userSpacesService
    _configuration = .init(initialValue: userSpacesService.configuration)
    self.activityReporter = activityReporter
    userSpacesService.$configuration
      .receive(on: DispatchQueue.main)
      .assign(to: &$configuration)
  }

  public func select(_ space: UserSpace) {
    userSpacesService.select(space)
    activityReporter.report(UserEvent.SelectSpace(space: space.logItemSpace))
  }
}

extension UserSpaceSwitcherViewModel {
  public static var mock: UserSpaceSwitcherViewModel {
    UserSpaceSwitcherViewModel(
      userSpacesService: .mock(status: .Mock.team), activityReporter: .mock)
  }
}
