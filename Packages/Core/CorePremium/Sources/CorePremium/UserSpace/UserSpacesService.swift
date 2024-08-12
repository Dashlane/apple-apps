import Combine
import DashlaneAPI
import Foundation

public enum UserSpace: Equatable, Sendable, Identifiable {
  case personal
  case team(Status.B2bStatus.CurrentTeam)
  case both

  public var id: String {
    switch self {
    case .personal:
      return "personal"
    case .team(let currentTeam):
      return currentTeam.personalDataId
    case .both:
      return ""
    }
  }

  public var personalDataId: String {
    switch self {
    case .personal, .both:
      return ""
    case let .team(team):
      return team.personalDataId
    }
  }

  public func match(_ space: UserSpace) -> Bool {
    switch self {
    case .both:
      return true
    case .team, .personal:
      return space == self
    }
  }
}

public final class UserSpacesService {
  public struct SpacesConfiguration: Equatable, Sendable {
    public fileprivate(set) var availableSpaces: [UserSpace] = [.personal]
    public var selectedSpace: UserSpace = .personal
    public var b2bStatus: Status.B2bStatus?
    public var currentTeam: CurrentTeam? {
      return b2bStatus?.currentActiveTeam
    }

    public init() {

    }
  }

  @Published
  public internal(set) var configuration: SpacesConfiguration = .init()

  private var subscription: AnyCancellable?

  public init(provider: some PremiumStatusProvider) {
    self.update(with: provider.status)

    subscription = provider.statusPublisher
      .sink { status in
        self.update(with: status)
      }

    configuration.selectedSpace = configuration.availableSpaces.first ?? .personal
  }

  private func update(with status: Status) {
    if configuration.b2bStatus != status.b2bStatus {
      configuration.b2bStatus = status.b2bStatus
    }

    let availableSpaces = status.availableSpaces
    if configuration.availableSpaces != availableSpaces {
      configuration.availableSpaces = availableSpaces
      if !configuration.availableSpaces.contains(configuration.selectedSpace) {
        configuration.selectedSpace = configuration.availableSpaces.first ?? .personal
      }
    }
  }

  @MainActor
  public func select(_ space: UserSpace) {
    guard configuration.availableSpaces.contains(space),
      configuration.selectedSpace != space
    else {
      return
    }

    configuration.selectedSpace = space
  }

}

extension Status {

  private var teamSpace: UserSpace? {
    guard let team = b2bStatus?.currentActiveTeam else {
      return nil
    }

    return .team(team)
  }

  private var personalSpace: UserSpace? {
    if b2bStatus?.statusCode == .inTeam, let team = b2bStatus?.currentTeam,
      team.teamInfo.personalSpaceEnabled == false
    {
      return nil
    } else {
      return .personal
    }
  }

  var availableSpaces: [UserSpace] {
    var spaces: [UserSpace] = []
    if let personalSpace = personalSpace {
      spaces.append(personalSpace)
    }

    if let teamSpace = teamSpace {
      spaces.append(teamSpace)
    }

    if spaces.count == 2 {
      spaces.insert(.both, at: 0)
    }

    return spaces
  }
}

extension Status.B2bStatus {
  fileprivate var currentActiveTeam: CurrentTeam? {
    guard statusCode == .inTeam else {
      return nil
    }

    return currentTeam
  }
}

extension PremiumStatusTeamInfo {
  public var shouldDeleteItemsOnRevoke: Bool {
    return self.removeForcedContentEnabled == true
  }
}

extension UserSpacesService {
  public static func mock(status: Status = .Mock.team) -> UserSpacesService {
    self.init(provider: .mock(status: status))
  }
}
