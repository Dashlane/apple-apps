import CoreActivityLogs
import CorePersonalData
import CorePremium
import CoreUserTracking
import Foundation
import VaultKit

@MainActor
public struct PhishingWarningViewModel {

  let credential: Credential
  let visitedWebsite: String

  public enum Action {
    case trustAndAutoFill
    case doNotAutoFill
  }

  private let userSpacesService: UserSpacesService
  private let sessionActivityReporter: ActivityReporterProtocol
  private let activityLogsService: ActivityLogsServiceProtocol
  private let autofillService: AutofillService
  private let database: ApplicationDatabase

  private let completion: (Action) -> Void

  public init(
    credential: Credential,
    visitedWebsite: String,
    userSpacesService: UserSpacesService,
    sessionActivityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    autofillService: AutofillService,
    database: ApplicationDatabase,
    completion: @escaping (PhishingWarningViewModel.Action) -> Void
  ) {
    self.credential = credential
    self.visitedWebsite = visitedWebsite
    self.userSpacesService = userSpacesService
    self.sessionActivityReporter = sessionActivityReporter
    self.activityLogsService = activityLogsService
    self.autofillService = autofillService
    self.database = database
    self.completion = completion
  }

  func trustWebsite() async {
    let event = UserEvent.AutofillDismiss(dismissType: .trust)
    await addWebsiteToTrustedURL()
    sessionActivityReporter.report(event)
    completion(.trustAndAutoFill)
  }

  func doNotTrustWebsite() {
    let event = UserEvent.AutofillDismiss(dismissType: .doNotTrust)
    sessionActivityReporter.report(event)
    completion(.doNotAutoFill)
  }

  private func addWebsiteToTrustedURL() async {
    let oldCredential = credential
    var credential = credential
    credential.linkedServices.associatedDomains.append(
      LinkedServices.AssociatedDomain(domain: visitedWebsite, source: .remember))

    if let space = userSpacesService.configuration.forcedSpace(for: credential) {
      credential.spaceId = space.personalDataId
    }

    _ = try? database.save(credential)
    await autofillService.save(credential, oldCredential: oldCredential)

    if let info = credential.reportableInfo() {
      try? activityLogsService.report(.update, for: info)
    }

    let userTrackingLogID = credential.userTrackingLogID
    let userTrackingSpace = credential.userTrackingSpace
    let hashedDomain = credential.hashedDomainForLogs()
    sessionActivityReporter.report(
      UserEvent.UpdateVaultItem(
        action: .edit,
        fieldsEdited: [.associatedWebsitesList],
        itemId: userTrackingLogID,
        itemType: .credential,
        space: userTrackingSpace))

    sessionActivityReporter.report(
      AnonymousEvent.UpdateCredential(
        action: .edit,
        associatedWebsitesAddedList: [self.visitedWebsite.hashedDomainForLogs().id ?? ""],
        associatedWebsitesRemovedList: [],
        domain: hashedDomain,
        space: userTrackingSpace))
  }

}

extension Credential {
  var trustedWebsite: String? {
    url?.domain?.name ?? linkedServices.associatedDomains.first?.domain
  }
}

extension PhishingWarningViewModel {

  static func mock() -> PhishingWarningViewModel {
    PhishingWarningViewModel(
      credential: PersonalDataMock.Credentials.netflix,
      visitedWebsite: "roguewebsite.com",
      userSpacesService: .mock(),
      sessionActivityReporter: .mock,
      activityLogsService: .mock(),
      autofillService: .fakeService,
      database: .mock(),
      completion: { _ in }
    )
  }
}
