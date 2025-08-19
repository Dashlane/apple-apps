import Combine
import CorePersonalData
import CorePremium
import CoreSettings
import DashlaneAPI
import Foundation
import SecurityDashboard
import UserTrackingFoundation
import VaultKit

struct VaultReportService {

  private struct CollectionsReportInfo {
    let collectionsPerItemAverageCount: Int
    let collectionsSharedCount: Int
    let collectionsTotalCount: Int
    let itemsPerCollectionAverageCount: Int
  }

  enum Error: Swift.Error {
    case uvvsNotEnabled
    case nothingToUpload
  }

  let identityDashboardService: IdentityDashboardServiceProtocol
  let userSettings: UserSettings
  let vaultItemsStore: VaultItemsStore
  let vaultCollectionsStore: VaultCollectionsStore
  let userSpacesService: UserSpacesService
  let activityReporter: ActivityReporterProtocol
  let apiClient: UserDeviceAPIClient.Useractivity
  let encryptedAPIClient: UserSecureNitroEncryptionAPIClient

  init(
    identityDashboardService: IdentityDashboardServiceProtocol,
    userSettings: UserSettings,
    vaultItemsStore: VaultItemsStore,
    vaultCollectionsStore: VaultCollectionsStore,
    apiClient: UserDeviceAPIClient,
    userSpacesService: UserSpacesService,
    activityReporter: ActivityReporterProtocol,
    encryptedAPIClient: UserSecureNitroEncryptionAPIClient
  ) {
    self.identityDashboardService = identityDashboardService
    self.userSettings = userSettings
    self.vaultItemsStore = vaultItemsStore
    self.vaultCollectionsStore = vaultCollectionsStore
    self.userSpacesService = userSpacesService
    self.activityReporter = activityReporter
    self.apiClient = apiClient.useractivity
    self.encryptedAPIClient = encryptedAPIClient
  }

  func report() {
    identityDashboardService
      .publisher(for: .securityDashboardDidRefresh)
      .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
      .sinkOnce { _ in
        self.uploadReport()
      }
  }

  private func uploadReport() {
    Task.detached(priority: .background) {
      try await reportUserVaultSnapshot()
      await reportVaultState(within: .personal)

      await reportVaultState(within: .global)

      guard let spaceId = userSpacesService.configuration.currentTeam?.personalDataId else {
        return
      }
      await reportVaultState(within: .team(spaceId: spaceId))

      try await uploadUserActivityLogs()
    }
  }

  func reportUserVaultSnapshot() async throws {
    guard let team = userSpacesService.configuration.currentTeam, team.isUVVSReportEnabled else {
      throw Error.uvvsNotEnabled
    }
    let credentials = vaultItemsStore.credentials
      .filter(bySpaceId: team.personalDataId)
    let vaultSnapshot = await identityDashboardService.vaultSnapshot(for: credentials)
    guard !vaultSnapshot.isEmpty else {
      throw Error.nothingToUpload
    }
    try await encryptedAPIClient.uvvs.uploadUserSnapshot(uvvs: vaultSnapshot)
  }

  private func uploadUserActivityLogs() async throws {
    let lastUploadDate: Date? = userSettings[.lastAggregatedLogsUploadDate]
    let personalReport = await identityDashboardService.report(spaceId: "")

    guard let personalSecurityIndex = personalReport.score else { return }

    let relativeStart = lastUploadDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    let relativeEnd = Date().timeIntervalSince1970

    let teamActivity: UserDeviceAPIClient.Useractivity.Create.Body.TeamActivity?
    if let team = userSpacesService.configuration.currentTeam {
      let teamReport = await identityDashboardService.report(spaceId: team.personalDataId)
      teamActivity = .init(
        teamId: team.teamId,
        activity: .init(
          averagePasswordStrength: Int(teamReport.allCredentialsReport.averagePasswordStrength),
          checkedPasswords: teamReport.allCredentialsReport.countsByFilter[.checked],
          compromisedPasswords: teamReport.allCredentialsReport.compromisedCount,
          nbrPasswords: teamReport.allCredentialsReport.totalCount,
          passwordstrength019Count: teamReport.allCredentialsReport.countsByStrength[.veryUnsafe],
          passwordstrength2039Count: teamReport.allCredentialsReport.countsByStrength[.unsafe],
          passwordstrength4059Count: teamReport.allCredentialsReport.countsByStrength[.notSoSafe],
          passwordstrength6079Count: teamReport.allCredentialsReport.countsByStrength[.safe],
          passwordstrength80100Count: teamReport.allCredentialsReport.countsByStrength[.superSafe],
          reused: teamReport.allCredentialsReport.countsByFilter[.reused],
          safePasswords: teamReport.allCredentialsReport.totalCount
            - teamReport.allCredentialsReport.corruptedCount,
          securityIndex: teamReport.score,
          weakPasswords: teamReport.allCredentialsReport.countsByFilter[.weak]
        )
      )
    } else {
      teamActivity = nil
    }
    try await apiClient.create(
      relativeStart: Int(relativeStart),
      relativeEnd: Int(relativeEnd),
      userActivity: .init(securityIndex: personalSecurityIndex),
      teamActivity: teamActivity
    )
    self.userSettings[.lastAggregatedLogsUploadDate] = Date()
  }

  private func reportVaultState(within scope: VaultReportScope) async {
    let items = allItems.filter(bySpaceId: scope.spaceId)
    let collectionsReport = collectionsInfo(within: scope)
    let credentials = vaultItemsStore.credentials.filter(bySpaceId: scope.spaceId)

    let report = await identityDashboardService.report(spaceId: scope.spaceId)
    let generalReport = report.allCredentialsReport
    let darkWebAlertCount = identityDashboardService.breaches.filter { $0.breach.kind == .dataLeak }
      .count
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
    let collections = vaultCollectionsStore.collections
    let items = allItems.filter(bySpaceId: scope.spaceId)

    let collectionsPerItemAverageCount: Int
    if items.isEmpty {
      collectionsPerItemAverageCount = 0
    } else {
      let allItemsInCollections = collections.flatMap { $0.itemIds }
      let uniqueItemsCount = Set(allItemsInCollections).count
      if uniqueItemsCount == 0 {
        collectionsPerItemAverageCount = 0
      } else {
        collectionsPerItemAverageCount = Int(
          round(Float(allItemsInCollections.count) / Float(uniqueItemsCount)))
      }
    }

    let itemsPerCollectionAverageCount: Int
    let nonEmptyCollections = collections.filter { !$0.itemIds.isEmpty }
    if nonEmptyCollections.isEmpty {
      itemsPerCollectionAverageCount = 0
    } else {
      itemsPerCollectionAverageCount =
        collections.reduce(
          0,
          { acc, collection in
            acc + collection.itemIds.count
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
    let collections = collections(
      for: [.address, .company, .email, .identity, .phone, .website], in: scope)
    return itemTypeCounts(for: personalInfo, in: collections)
  }

  private func paymentsReport(within scope: VaultReportScope) -> Definition.ItemTypeCounts {
    let payments = self.payments.filter(bySpaceId: scope.spaceId)
    let collections = collections(for: [.creditCard, .bankAccount], in: scope)
    return itemTypeCounts(for: payments, in: collections)
  }

  private func idsReport(within scope: VaultReportScope) -> Definition.ItemTypeCounts {
    let ids = self.ids.filter(bySpaceId: scope.spaceId)
    let collections = collections(
      for: [.driverLicence, .taxNumber, .socialSecurityInfo, .passport, .idCard], in: scope)
    return itemTypeCounts(for: ids, in: collections)
  }

  private func itemTypeCounts(for items: [VaultItem], in collections: [PrivateCollection])
    -> Definition.ItemTypeCounts
  {
    return Definition.ItemTypeCounts(
      collectionsCount: collections.count,
      collectionsSharedCount: collections.filter { $0.isShared }.count,
      multipleCollectionsCount: itemsInMultipleCollections(for: items, in: collections).count,
      multipleCollectionsSharedCount: itemsInMultipleCollections(
        for: items, in: collections, isSharedFilter: true
      ).count,
      sharedCount: items.filter { $0.isShared }.count,
      singleCollectionCount: itemsInSingleCollection(for: items, in: collections).count,
      singleCollectionSharedCount: itemsInSingleCollection(
        for: items, in: collections, isSharedFilter: true
      ).count,
      totalCount: items.count
    )
  }
}

extension VaultReportService {
  fileprivate func collections(for types: Set<XMLDataType?>, in scope: VaultReportScope)
    -> [PrivateCollection]
  {
    vaultCollectionsStore
      .collections
      .compactMap(\.privateCollection)
      .filter { collection in
        collection.items.contains { types.contains($0.type) }
      }
      .filter(bySpaceId: scope.spaceId)
  }

  fileprivate func itemsInSingleCollection(
    for items: [VaultItem], in collections: [PrivateCollection], isSharedFilter: Bool = false
  ) -> [VaultItem] {
    if isSharedFilter {
      return items.filter { item in
        collections.filter { $0.isShared && $0.contains(item) }.count == 1
      }
    } else {
      return items.filter { item in collections.filter { $0.contains(item) }.count == 1 }
    }
  }

  fileprivate func itemsInMultipleCollections(
    for items: [VaultItem], in collections: [PrivateCollection], isSharedFilter: Bool = false
  ) -> [VaultItem] {
    if isSharedFilter {
      return items.filter { item in
        collections.filter { $0.isShared && $0.contains(item) }.count > 1
      }
    } else {
      return items.filter { item in collections.filter { $0.contains(item) }.count > 1 }
    }
  }

  fileprivate var allItems: [VaultItem] {
    var allItems: [VaultItem] = credentials
    allItems.append(contentsOf: secureNotes)
    allItems.append(contentsOf: payments)
    allItems.append(contentsOf: personalInfo)
    allItems.append(contentsOf: ids)
    return allItems
  }

  fileprivate var credentials: [VaultItem] {
    vaultItemsStore.credentials
  }

  fileprivate var secureNotes: [VaultItem] {
    vaultItemsStore.secureNotes
  }

  fileprivate var personalInfo: [VaultItem] {
    var personalInfo: [VaultItem] = vaultItemsStore.addresses
    personalInfo.append(contentsOf: vaultItemsStore.companies)
    personalInfo.append(contentsOf: vaultItemsStore.emails)
    personalInfo.append(contentsOf: vaultItemsStore.identities)
    personalInfo.append(contentsOf: vaultItemsStore.phones)
    personalInfo.append(contentsOf: vaultItemsStore.websites)
    return personalInfo
  }

  fileprivate var payments: [VaultItem] {
    var payments: [VaultItem] = vaultItemsStore.creditCards
    payments.append(contentsOf: vaultItemsStore.bankAccounts)
    return payments
  }

  fileprivate var ids: [VaultItem] {
    var ids: [VaultItem] = vaultItemsStore.drivingLicenses
    ids.append(contentsOf: vaultItemsStore.fiscalInformation)
    ids.append(contentsOf: vaultItemsStore.idCards)
    ids.append(contentsOf: vaultItemsStore.passports)
    ids.append(contentsOf: vaultItemsStore.socialSecurityInformation)
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

extension Array where Element == Credential {
  fileprivate func filter(bySpaceId spaceId: String?) -> [Element] {
    guard let spaceId = spaceId else { return self }
    return filter { $0.spaceId == spaceId }
  }
}

extension Array where Element == PrivateCollection {
  fileprivate func filter(bySpaceId spaceId: String?) -> [Element] {
    guard let spaceId = spaceId else { return self }
    return filter { ($0.spaceId ?? "") == spaceId }
  }
}

extension Array where Element == VaultItem {
  fileprivate func filter(bySpaceId spaceId: String?) -> [Element] {
    guard let spaceId = spaceId else { return self }
    return filter { $0.spaceId == spaceId }
  }
}
