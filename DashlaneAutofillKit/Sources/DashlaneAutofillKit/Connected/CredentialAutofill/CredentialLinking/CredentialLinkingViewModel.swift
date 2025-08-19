import AutofillKit
import CorePersonalData
import CorePremium
import CoreTeamAuditLogs
import Foundation
import IconLibrary
import LoginKit
import UserTrackingFoundation
import VaultKit

final class CredentialLinkingViewModel: SessionServicesInjecting {

  var credential: Credential
  let visitedWebsite: String

  private let database: ApplicationDatabase
  private let autofillService: AutofillStateServiceProtocol
  private let domainLibrary: DomainIconLibraryProtocol
  private let userSpacesService: UserSpacesService
  private let sessionActivityReporter: ActivityReporterProtocol
  private let teamAuditLogsService: TeamAuditLogsServiceProtocol
  private let completion: () -> Void

  init(
    credential: Credential,
    visitedWebsite: String,
    database: ApplicationDatabase,
    autofillService: AutofillStateServiceProtocol,
    domainLibrary: DomainIconLibraryProtocol,
    userSpacesService: UserSpacesService,
    sessionActivityReporter: ActivityReporterProtocol,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    completion: @escaping () -> Void
  ) {
    self.credential = credential
    self.visitedWebsite = visitedWebsite
    self.database = database
    self.autofillService = autofillService
    self.domainLibrary = domainLibrary
    self.userSpacesService = userSpacesService
    self.sessionActivityReporter = sessionActivityReporter
    self.teamAuditLogsService = teamAuditLogsService
    self.completion = completion
  }

  func makeIconViewModel() -> VaultItemIconViewModel {
    VaultItemIconViewModel(item: credential, domainIconLibrary: domainLibrary)
  }

  func link() async {
    let oldCredential = credential
    credential.linkedServices.associatedDomains.append(
      LinkedServices.AssociatedDomain(domain: visitedWebsite, source: .remember))

    if let space = userSpacesService.configuration.forcedSpace(for: credential) {
      credential.spaceId = space.personalDataId
    }

    _ = try? database.save(credential)
    await autofillService.save(credential, oldCredential: oldCredential)

    let logCredential = credential
    sessionActivityReporter.report(
      UserEvent.CallToAction(
        callToActionList: [.linkWebsite, .doNotLinkWebsite],
        chosenAction: .linkWebsite,
        hasChosenNoAction: false))

    sessionActivityReporter.report(
      UserEvent.UpdateVaultItem(
        action: .edit,
        fieldsEdited: [.associatedWebsitesList],
        itemId: logCredential.userTrackingLogID,
        itemType: .credential,
        space: logCredential.userTrackingSpace))

    sessionActivityReporter.report(
      AnonymousEvent.UpdateCredential(
        action: .edit,
        associatedWebsitesAddedList: [self.visitedWebsite.hashedDomainForLogs().id ?? ""],
        associatedWebsitesRemovedList: [],
        domain: logCredential.hashedDomainForLogs(),
        space: logCredential.userTrackingSpace))

    try? teamAuditLogsService.report(
      credential.generateReportableInfo(with: .update)
    )

    self.completion()
  }

  func ignore() {
    sessionActivityReporter.report(
      UserEvent.CallToAction(
        callToActionList: [.linkWebsite, .doNotLinkWebsite],
        chosenAction: .doNotLinkWebsite,
        hasChosenNoAction: false))

    completion()
  }
}

extension CredentialLinkingViewModel {
  static var mock: CredentialLinkingViewModel {
    CredentialLinkingViewModel(
      credential: PersonalDataMock.Credentials.netflix,
      visitedWebsite: "roguewebsite.com",
      database: .mock(),
      autofillService: .mock,
      domainLibrary: FakeDomainIconLibrary(icon: .none),
      userSpacesService: .mock(),
      sessionActivityReporter: .mock,
      teamAuditLogsService: .mock()
    ) {}
  }
}
