import Foundation
import CoreUserTracking
import Combine
import DashlaneAppKit
import CorePersonalData
import SecurityDashboard
import CoreSettings

struct VaultReportService {

    let identityDashboardService: IdentityDashboardService
    let userSettings: UserSettings
    let vaultItemsService: VaultItemsService
    let teamSpacesService: TeamSpacesService
    let activityReporter: ActivityReporterProtocol

    init(identityDashboardService: IdentityDashboardService,
         userSettings: UserSettings,
         vaultItemsService: VaultItemsService,
         teamSpacesService: TeamSpacesService,
         activityReporter: ActivityReporterProtocol) {
        self.identityDashboardService = identityDashboardService
        self.userSettings = userSettings
        self.vaultItemsService = vaultItemsService
        self.teamSpacesService = teamSpacesService
        self.activityReporter = activityReporter
    }

    func report() {
        Task(priority: .utility) {
            await reportVaultState(within: .personal)

            await reportVaultState(within: .global)

            guard let spaceId = teamSpacesService.availableBusinessTeam?.teamId else {
                return
            }
            await reportVaultState(within: .team(spaceId: spaceId))
        }
    }

    private func reportVaultState(within scope: VaultReportScope) async {

        let credentials = vaultItemsService.credentials.filter(bySpaceId: scope.spaceId)
        let report = await identityDashboardService.report(spaceId: scope.spaceId)

        let generalReport = report.allCredentialsReport

        let darkWebAlertCount = identityDashboardService.breaches.filter { $0.breach.kind == .dataLeak }.count
        let securityAlertsCount = identityDashboardService.breaches.count

        let activeBreaches = await identityDashboardService.trayAlerts()
        let darkWebActiveAlertsCount = activeBreaches.filter { $0.breach.kind == .dataLeak }.count
        let securityAlertsActiveCount = activeBreaches.count

        let safePasswordsCount = generalReport.totalCount - generalReport.corruptedCount

        let credentialsWithOTPCount = credentials.filter { $0.otpURL != nil }.count
        let credentialsWithAutologinDisabled = credentials.filter { !$0.autoLogin }.count
        let protectedCredentialsCount = credentials.filter { $0.isProtected }.count

        let excludedCredentialsCount = credentials.filter { $0.disabledForPasswordAnalysis }.count
        let vaultState = UserEvent.VaultReport(darkWebAlertsActiveCount: darkWebActiveAlertsCount,
                                               darkWebAlertsCount: darkWebAlertCount,
                                               passwordsCompromisedCount: generalReport.compromisedCount,
                                               passwordsCompromisedThroughDarkWebCount: generalReport.compromisedByDataLeakCount,
                                               passwordsExcludedCount: excludedCredentialsCount,
                                               passwordsProtectedWithMasterPasswordCount: protectedCredentialsCount,
                                               passwordsReusedCount: generalReport.countsByFilter[.reused] ?? 0,
                                               passwordsSafeCount: safePasswordsCount,
                                               passwordsTotalCount: generalReport.totalCount,
                                               passwordsWeakCount: generalReport.countsByFilter[.weak] ?? 0,
                                               passwordsWithAutologinDisabledCount: credentialsWithAutologinDisabled,
                                               passwordsWithOtpCount: credentialsWithOTPCount,
                                               scope: scope.definitionScope,
                                               securityAlertsActiveCount: securityAlertsActiveCount,
                                               securityAlertsCount: securityAlertsCount,
                                               securityScore: report.score ?? 0)

        self.activityReporter.report(vaultState)
    }

}

private enum VaultReportScope {
    case personal
    case team(spaceId: String)
    case global

        var spaceId: String? {
        switch self {
        case .personal:
            return ""
        case let .team(spaceId):
            return spaceId
        case .global:
            return nil
        }
    }

    var definitionScope: Definition.Scope {
        switch self {
        case .personal: return .personal
        case .global: return .global
        case .team: return .team
        }
    }
}

private extension Array where Element == Credential {

    func filter(bySpaceId spaceId: String?) -> [Element] {
        guard let spaceId = spaceId else {
            return self
        }
        return self.filter { $0.spaceId == spaceId }
    }
}
