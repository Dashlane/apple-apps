import Foundation
import DashlaneReportKit
import DashlaneAppKit
import CorePremium

struct TeamSpacesUsageLogger {

    let usageLogService: UsageLogServiceProtocol

    func logTeamSpaceSwitched(anonymousId: String) {

    }

    func logPolicySettings(spaces: [UserSpace]) {
        spaces.compactMap { space -> BusinessTeam? in
            guard case let .business(businessTeam) = space else { return nil }
            return businessTeam
        }
        .flatMap { businessSpace -> [UsageLogCode108TeamSettings] in
            let lockOnExit = UsageLogCode108TeamSettings(spaceId: businessSpace.anonymousTeamId,
                                                         type: .lockOnExit,
                                                         value: businessSpace.lockOnExit)
            let sharing = UsageLogCode108TeamSettings(spaceId: businessSpace.anonymousTeamId,
                                                      type: .sharing,
                                                      value: businessSpace.sharing)
            let emergency = UsageLogCode108TeamSettings(spaceId: businessSpace.anonymousTeamId,
                                                        type: .emergency,
                                                        value: businessSpace.emergency)
            let smartCategorization = UsageLogCode108TeamSettings(spaceId: businessSpace.anonymousTeamId,
                                                                  type: .smartCategorization,
                                                                  value: businessSpace.teamDomainsCount)
            let forcedCategorization = UsageLogCode108TeamSettings(spaceId: businessSpace.anonymousTeamId,
                                                                   type: .forcedCategorization,
                                                                   value: businessSpace.removeForcedContent)
            let removeForcedContent = UsageLogCode108TeamSettings(spaceId: businessSpace.anonymousTeamId,
                                                                  type: .removeRevoked,
                                                                  value: businessSpace.removeForcedContent)
            return [lockOnExit, sharing, emergency, smartCategorization, removeForcedContent, forcedCategorization]
        }
        .forEach { usageLogService.post($0) }
    }
}

fileprivate extension BusinessTeam {
    var lockOnExit: String {
        space.info.lockOnExit == true ? "enabled" : "disabled"
    }

    var sharing: String {
        space.info.sharingDisabled == true ? "disabled" : "enabled"
    }

    var emergency: String {
        space.info.emergencyDisabled == true ? "disabled" : "enabled"
    }

    var teamDomainsCount: String {
        "\(space.info.teamDomains?.count ?? 0)"
    }

    var removeForcedContent: String {
        space.info.removeForcedContentEnabled == true ? "enabled" : "disabled"
    }

    var forcedCategorization: String {
        shouldForceSpace ? "enabled" : "disabled"
    }
}
