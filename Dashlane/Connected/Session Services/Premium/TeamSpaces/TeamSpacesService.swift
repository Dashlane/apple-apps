import Foundation
import SwiftUI
import Combine
import CorePremium
import CorePersonalData
import DashTypes
import DashlaneAppKit
import VaultKit

public final class TeamSpacesService {

            @Published
    var selectedSpace: UserSpace = .both {
        didSet {
            usageLogService.teamSpaceLogger.logTeamSpaceSwitched(anonymousId: selectedSpace.anonymousIdForUsageLogs)
        }
    }

                @Published
    var availableSpaces: [UserSpace] = [] {
        didSet {
            usageLogService.teamSpaceLogger.logPolicySettings(spaces: availableSpaces)
        }
    }

    var hasBusinessSpace: Bool {
        return availableSpaces.count > 1
    }

    var availableBusinessTeam: BusinessTeam? {
        return businessTeamsInfo.availableBusinessTeam
    }

        @Published
    public var businessTeamsInfo: BusinessTeamsInfo = BusinessTeamsInfo(businessTeams: [])

    private var subscriptions = Set<AnyCancellable>()

        private init(selectedSpace: UserSpace, availableSpaces: [UserSpace], businessTeamsInfo: BusinessTeamsInfo = BusinessTeamsInfo(businessTeams: [])) {
        self.selectedSpace = selectedSpace
        self.availableSpaces = availableSpaces
        self.usageLogService = UsageLogService.fakeService
        self.businessTeamsInfo = businessTeamsInfo
    }

    let usageLogService: UsageLogServiceProtocol

    init(database: ApplicationDatabase,
         usageLogService: UsageLogServiceProtocol,
         premiumService: PremiumService,
         syncedSettings: SyncedSettingsService,
         networkEngine: LegacyWebService,
         sharingService: SharedVaultHandling,
         logger: Logger) {
        self.usageLogService = usageLogService

        configureBusinessInfo(using: premiumService, syncedSettings: syncedSettings)

                let revokeHandler = TeamSpacesRevokeHandler(database: database,
                                                    networkEngine: networkEngine,
                                                    sharingService: sharingService,
                                                    logger: logger)
        configureRevoke(with: revokeHandler, logger: logger, syncedSettings: syncedSettings)
        configureUserSpaces()
    }

    private func configureBusinessInfo(using premiumService: PremiumService, syncedSettings: SyncedSettingsService) {
                premiumService.$status
            .compactMap { $0 }
            .map { [weak self] status  in
                return status.spaces?.compactMap { space in
                    return self?.businessTeam(from: space, using: syncedSettings)
                    } ?? []
        }
        .removeDuplicates()
        .map(BusinessTeamsInfo.init)
        .assign(to: \.businessTeamsInfo, on: self)
        .store(in: &subscriptions)
    }

    private func businessTeam(from space: Space, using syncedSettings: SyncedSettingsService) -> BusinessTeam {
        let anonymousTeamId: String

        if let savedId: String = syncedSettings[\.spaceAnonIds][space.teamId] {
            anonymousTeamId = savedId
        } else {
            anonymousTeamId = UUID().uuidString
            syncedSettings[\.spaceAnonIds][space.teamId] = anonymousTeamId
        }

        return BusinessTeam(space: space, anonymousTeamId: anonymousTeamId)
    }

    private func configureRevoke(with revokeHandler: TeamSpacesRevokeHandler, logger: Logger, syncedSettings: SyncedSettingsService) {
        $businessTeamsInfo
            .map { Publishers.Sequence<[BusinessTeam], Never>(sequence: $0.businessTeams.filter { $0.space.status == .revoked }) }
            .switchToLatest()
            .setFailureType(to: Error.self)
            .flatMap(revokeHandler.updateVaultForRevokedBusinessTeam)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case let .failure(error):
                        logger.error("Revoke business team error", error: error)
                    case .finished: break
                }
            }, receiveValue: { businessTeam in
                let previousMembershipStatus = syncedSettings.previousStatusMemberShip(forTeam: businessTeam.teamId)
                if previousMembershipStatus != businessTeam.space.status {
                                        syncedSettings.setPreviousMembershipStatus(businessTeam.space.status, forTeam: businessTeam.teamId)
                }

            }).store(in: &subscriptions)
    }

    private func configureUserSpaces() {
        $businessTeamsInfo.map { info in
            guard let team = info.availableBusinessTeam else {
                return [.both]
            }

            return [.both,
                    .personal,
                    .business(team)]
        }
        .removeDuplicates()
        .assign(to: \.availableSpaces, on: self)
        .store(in: &subscriptions)

        self.$availableSpaces.compactMap { [weak self] availableSpaces in
            guard let self = self else {
                return nil
            }
                        if !availableSpaces.contains(self.selectedSpace) {
                return availableSpaces.first
            }
            return nil
        }
        .removeDuplicates()
        .assign(to: \.selectedSpace, on: self)
        .store(in: &subscriptions)
    }
}

extension TeamSpacesService {
    static func mock(selectedSpace: UserSpace = .personal, availableSpaces: [UserSpace]  = [.personal], businessTeamsInfo: BusinessTeamsInfo = BusinessTeamsInfo(businessTeams: [])) -> TeamSpacesService {
        TeamSpacesService(selectedSpace: selectedSpace, availableSpaces: availableSpaces, businessTeamsInfo: businessTeamsInfo)
    }
}

extension TeamSpacesService {
        func userSpace(for item: VaultItem) -> UserSpace? {
        return businessTeamsInfo.userSpace(forSpaceId: item.spaceId)
    }

            func displayedUserSpace(for item: VaultItem) -> UserSpace? {
        if hasBusinessSpace {
            let itemSpace = userSpace(for: item)
            return selectedSpace != itemSpace ? itemSpace : nil
        } else {
            return nil
        }
    }

    func businessTeam(for item: VaultItem) -> BusinessTeam? {
        guard let userspace = userSpace(for: item), case let UserSpace.business(businessTeam) = userspace else {
            return nil
        }
        return businessTeam
    }

        func userSpace(withId teamId: String) -> UserSpace? {
        return businessTeamsInfo.userSpace(forSpaceId: teamId)
    }

    func businessTeam(withId teamId: String) -> BusinessTeam? {
        guard let userspace = userSpace(withId: teamId), case let UserSpace.business(businessTeam) = userspace else {
            return nil
        }
        return businessTeam
    }
}

private extension SyncedSettingsService {
    private var previousStatusKeyPrefix: String { "TeamSpacePreviousStatus" }
    func previousStatusMemberShip(forTeam teamId: String) -> Space.MembershipStatus? {
        let key =  previousStatusKeyPrefix.appending(teamId)
        let value = self[\.iOSInfo][key]
        return value.flatMap(Space.MembershipStatus.init)
    }

    func setPreviousMembershipStatus( _ previousMembershipStatus: Space.MembershipStatus, forTeam teamId: String) {
        let key = previousStatusKeyPrefix.appending(teamId)
        self[\.iOSInfo][key] = previousMembershipStatus.rawValue
    }
}

extension TeamSpacesService: CorePremium.TeamSpacesServiceProtocol {
    public var availableSpacesPublisher: Published<[UserSpace]>.Publisher { $availableSpaces }
    public var businessTeamsInfoPublisher: Published<BusinessTeamsInfo>.Publisher { $businessTeamsInfo }
}
