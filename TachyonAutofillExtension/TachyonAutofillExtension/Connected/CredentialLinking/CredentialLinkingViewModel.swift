import AutofillKit
import CoreActivityLogs
import CorePersonalData
import CorePremium
import CoreUserTracking
import Foundation
import IconLibrary
import LoginKit
import VaultKit

final class CredentialLinkingViewModel: SessionServicesInjecting {

  var credential: Credential
  let visitedWebsite: String

  private let database: ApplicationDatabase
  private let autofillService: AutofillService
  private let domainLibrary: DomainIconLibrary
  private let userSpacesService: UserSpacesService
  private let sessionActivityReporter: ActivityReporterProtocol
  private let activityLogsService: ActivityLogsServiceProtocol
  private let completion: () -> Void

  init(
    credential: Credential,
    visitedWebsite: String,
    database: ApplicationDatabase,
    autofillService: AutofillService,
    domainLibrary: DomainIconLibrary,
    userSpacesService: UserSpacesService,
    sessionActivityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    completion: @escaping () -> Void
  ) {
    self.credential = credential
    self.visitedWebsite = visitedWebsite
    self.database = database
    self.autofillService = autofillService
    self.domainLibrary = domainLibrary
    self.userSpacesService = userSpacesService
    self.sessionActivityReporter = sessionActivityReporter
    self.activityLogsService = activityLogsService
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
    if let info = credential.reportableInfo() {
      try? activityLogsService.report(.update, for: info)
    }

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
