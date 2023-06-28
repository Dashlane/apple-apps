import Foundation
import CoreUserTracking
import Combine
import DashlaneAppKit
import CorePersonalData
import SecurityDashboard
import CoreSettings
import VaultKit
import DashlaneAPI

struct VaultReportService {

    private struct CollectionsReportInfo {
        let collectionsPerItemAverageCount: Int
        let collectionsSharedCount: Int
        let collectionsTotalCount: Int
        let itemsPerCollectionAverageCount: Int
    }

    let identityDashboardService: IdentityDashboardService
    let userSettings: UserSettings
    let vaultItemsService: VaultItemsService
    let teamSpacesService: TeamSpacesService
    let activityReporter: ActivityReporterProtocol
    let apiClient: UserDeviceAPIClient.Useractivity

    init(identityDashboardService: IdentityDashboardService,
         userSettings: UserSettings,
         vaultItemsService: VaultItemsService,
         apiClient: UserDeviceAPIClient.Useractivity,
         teamSpacesService: TeamSpacesService,
         activityReporter: ActivityReporterProtocol) {
        self.identityDashboardService = identityDashboardService
        self.userSettings = userSettings
        self.vaultItemsService = vaultItemsService
        self.teamSpacesService = teamSpacesService
        self.activityReporter = activityReporter
        self.apiClient = apiClient
    }

    func report() {
        identityDashboardService.notificationManager
            .publisher(for: .securityDashboardDidRefresh)
            .sinkOnce { _ in
                self.uploadReport()
            }
    }

    private func uploadReport() {
        Task(priority: .utility) {
            await reportVaultState(within: .personal)

            await reportVaultState(within: .global)

            guard let spaceId = teamSpacesService.availableBusinessTeam?.teamId else {
                return
            }
            await reportVaultState(within: .team(spaceId: spaceId))

            try await uploadUserActivityLogs()
        }
    }

    private func uploadUserActivityLogs() async throws {
        let lastUploadDate: Date? = userSettings[.lastAggregatedLogsUploadDate]
        let personalReport = await identityDashboardService.report(spaceId: "")
        let teamId = teamSpacesService.availableBusinessTeam?.teamId

        guard let personalSecurityIndex = personalReport.score else { return }

                        let relativeStart = lastUploadDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let relativeEnd = Date().timeIntervalSince1970

        let teamActivity: UserDeviceAPIClient.Useractivity.Create.TeamActivity?
        if let teamId, let intTeamId = Int(teamId) {
            let securityIndex = await identityDashboardService.report(spaceId: teamId).score
            teamActivity = .init(teamId: intTeamId, activity: .init(securityIndex: securityIndex))
        } else {
            teamActivity = nil
        }
        try await apiClient.create(relativeStart: Int(relativeStart),
                                   relativeEnd: Int(relativeEnd),
                                   userActivity: .init(securityIndex: personalSecurityIndex),
                                   teamActivity: teamActivity)
        self.userSettings[.lastAggregatedLogsUploadDate] = Date()
    }

    private func reportVaultState(within scope: VaultReportScope) async {
        let items = allItems.filter(bySpaceId: scope.spaceId)
        let collectionsReport = collectionsInfo(within: scope)
        let credentials = vaultItemsService.credentials.filter(bySpaceId: scope.spaceId)

        let report = await identityDashboardService.report(spaceId: scope.spaceId)
        let generalReport = report.allCredentialsReport
        let darkWebAlertCount = identityDashboardService.breaches.filter { $0.breach.kind == .dataLeak }.count
        let activeBreaches = await identityDashboardService.trayAlerts()

        let vaultState = UserEvent.VaultReport(
            collectionsPerItemAverageCount: collectionsReport.collectionsPerItemAverageCount,
            collectionsSharedCount: collectionsReport.collectionsSharedCount,
            collectionsTotalCount: collectionsReport.collectionsTotalCount,
            darkWebAlertsActiveCount: activeBreaches.filter { $0.breach.kind == .dataLeak }.count,
            darkWebAlertsCount: darkWebAlertCount,
            ids: idsReport(within: scope),
            itemsPerCollectionAverageCount: collectionsReport.itemsPerCollectionAverageCount,
            itemsSharedCount: items.filter { $0.isShared }.count,
            itemsTotalCount: items.count,
            passwords: passwordsReport(within: scope),
            passwordsCompromisedCount: generalReport.compromisedCount,
            passwordsCompromisedThroughDarkWebCount: generalReport.compromisedByDataLeakCount,
            passwordsExcludedCount: credentials.filter { $0.disabledForPasswordAnalysis }.count,
            passwordsProtectedWithMasterPasswordCount: credentials.filter { $0.isProtected }.count,
            passwordsReusedCount: generalReport.countsByFilter[.reused] ?? 0,
            passwordsSafeCount: generalReport.totalCount - generalReport.corruptedCount,
            passwordsWeakCount: generalReport.countsByFilter[.weak] ?? 0,
            passwordsWithAutologinDisabledCount: credentials.filter { !$0.autoLogin }.count,
            passwordsWithOtpCount: credentials.filter { $0.otpURL != nil }.count,
            payments: paymentsReport(within: scope),
            personalInfo: personalInfoReport(within: scope),
            scope: scope.definitionScope,
            secureNotes: secureNotesReport(within: scope),
            securityAlertsActiveCount: activeBreaches.count,
            securityAlertsCount: identityDashboardService.breaches.count,
            securityScore: report.score ?? 0
        )

        activityReporter.report(vaultState)
    }

    private func collectionsInfo(within scope: VaultReportScope) -> CollectionsReportInfo {
        let collections = vaultItemsService.collections
        let items = allItems.filter(bySpaceId: scope.spaceId)

        let collectionsPerItemAverageCount: Int
        if items.isEmpty {
            collectionsPerItemAverageCount = 0
        } else {
            let allItemsInCollections = collections.flatMap { $0.items }
            let uniqueItemsCount = Set(allItemsInCollections.map(\.id)).count
            if uniqueItemsCount == 0 {
                collectionsPerItemAverageCount = 0
            } else {
                collectionsPerItemAverageCount = Int(round(Float(allItemsInCollections.count) / Float(uniqueItemsCount)))
            }
        }

        let itemsPerCollectionAverageCount: Int
        let nonEmptyCollections = collections.filter { !$0.items.isEmpty }
        if nonEmptyCollections.isEmpty {
            itemsPerCollectionAverageCount = 0
        } else {
            itemsPerCollectionAverageCount = collections.reduce(0, { acc, collection in
                acc + collection.items.count
            }) / nonEmptyCollections.count
        }

        return CollectionsReportInfo(
            collectionsPerItemAverageCount: collectionsPerItemAverageCount,
            collectionsSharedCount: collections.filter { $0.isShared }.count,
            collectionsTotalCount: collections.count,
            itemsPerCollectionAverageCount: itemsPerCollectionAverageCount
        )
    }

    private func passwordsReport(within scope: VaultReportScope) -> Definition.ItemTypeCounts {
        let credentials = self.credentials.filter(bySpaceId: scope.spaceId)
        let collections = collections(for: [.credential], in: scope)
        return itemTypeCounts(for: credentials, in: collections)
    }

    private func secureNotesReport(within scope: VaultReportScope) -> Definition.ItemTypeCounts {
        let secureNotes = self.secureNotes.filter(bySpaceId: scope.spaceId)
        let collections = collections(for: [.secureNote], in: scope)
        return itemTypeCounts(for: secureNotes, in: collections)
    }

    private func personalInfoReport(within scope: VaultReportScope) -> Definition.ItemTypeCounts {
        let personalInfo = self.personalInfo.filter(bySpaceId: scope.spaceId)
        let collections = collections(for: [.address, .company, .email, .identity, .phone, .website], in: scope)
        return itemTypeCounts(for: personalInfo, in: collections)
    }

    private func paymentsReport(within scope: VaultReportScope) -> Definition.ItemTypeCounts {
        let payments = self.payments.filter(bySpaceId: scope.spaceId)
        let collections = collections(for: [.creditCard, .bankAccount], in: scope)
        return itemTypeCounts(for: payments, in: collections)
    }

    private func idsReport(within scope: VaultReportScope) -> Definition.ItemTypeCounts {
        let ids = self.ids.filter(bySpaceId: scope.spaceId)
        let collections = collections(for: [.driverLicence, .taxNumber, .socialSecurityInfo, .passport, .idCard], in: scope)
        return itemTypeCounts(for: ids, in: collections)
    }

    private func itemTypeCounts(for items: [VaultItem], in collections: [VaultCollection]) -> Definition.ItemTypeCounts {
        return Definition.ItemTypeCounts(
            collectionsCount: collections.count,
            collectionsSharedCount: collections.filter { $0.isShared }.count,
            multipleCollectionsCount: itemsInMultipleCollections(for: items, in: collections).count,
            multipleCollectionsSharedCount: itemsInMultipleCollections(for: items, in: collections, isSharedFilter: true).count,
            sharedCount: items.filter { $0.isShared }.count,
            singleCollectionCount: itemsInSingleCollection(for: items, in: collections).count,
            singleCollectionSharedCount: itemsInSingleCollection(for: items, in: collections, isSharedFilter: true).count,
            totalCount: items.count
        )
    }
}

private extension VaultReportService {
    func collections(for types: [XMLDataType], in scope: VaultReportScope) -> [VaultCollection] {
        vaultItemsService
            .collections
            .filter { !$0.items.filter { types.contains($0.type) }.isEmpty }
            .filter(bySpaceId: scope.spaceId)
    }

    func itemsInSingleCollection(for items: [VaultItem], in collections: [VaultCollection], isSharedFilter: Bool = false) -> [VaultItem] {
        if isSharedFilter {
            return items.filter { item in collections.filter { $0.isShared && $0.contains(item) }.count == 1 }
        } else {
            return items.filter { item in collections.filter { $0.contains(item) }.count == 1 }
        }
    }

    func itemsInMultipleCollections(for items: [VaultItem], in collections: [VaultCollection], isSharedFilter: Bool = false) -> [VaultItem] {
        if isSharedFilter {
            return items.filter { item in collections.filter { $0.isShared && $0.contains(item) }.count > 1 }
        } else {
            return items.filter { item in collections.filter { $0.contains(item) }.count > 1 }
        }
    }

    var allItems: [VaultItem] {
        var allItems: [VaultItem] = credentials
        allItems.append(contentsOf: secureNotes)
        allItems.append(contentsOf: payments)
        allItems.append(contentsOf: personalInfo)
        allItems.append(contentsOf: ids)
        return allItems
    }

    var credentials: [VaultItem] {
        vaultItemsService.credentials
    }

    var secureNotes: [VaultItem] {
        vaultItemsService.secureNotes
    }

    var personalInfo: [VaultItem] {
        var personalInfo: [VaultItem] = vaultItemsService.addresses
        personalInfo.append(contentsOf: vaultItemsService.companies)
        personalInfo.append(contentsOf: vaultItemsService.emails)
        personalInfo.append(contentsOf: vaultItemsService.identities)
        personalInfo.append(contentsOf: vaultItemsService.phones)
        personalInfo.append(contentsOf: vaultItemsService.websites)
        return personalInfo
    }

    var payments: [VaultItem] {
        var payments: [VaultItem] = vaultItemsService.creditCards
        payments.append(contentsOf: vaultItemsService.bankAccounts)
        return payments
    }

    var ids: [VaultItem] {
        var ids: [VaultItem] = vaultItemsService.drivingLicenses
        ids.append(contentsOf: vaultItemsService.fiscalInformation)
        ids.append(contentsOf: vaultItemsService.idCards)
        ids.append(contentsOf: vaultItemsService.passports)
        ids.append(contentsOf: vaultItemsService.socialSecurityInformation)
        return ids
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
        guard let spaceId = spaceId else { return self }
        return filter { $0.spaceId == spaceId }
    }
}

private extension Array where Element == VaultCollection {
    func filter(bySpaceId spaceId: String?) -> [Element] {
        guard let spaceId = spaceId else { return self }
        return filter { ($0.spaceId ?? "") == spaceId }
    }
}

private extension Array where Element == VaultItem {
    func filter(bySpaceId spaceId: String?) -> [Element] {
        guard let spaceId = spaceId else { return self }
        return filter { $0.spaceId == spaceId }
    }
}
