import Foundation
import VaultKit
import CorePersonalData
import CoreUserTracking
import CorePremium
import IconLibrary
import AutofillKit
import CoreActivityLogs
import LoginKit

final class CredentialLinkingViewModel: ObservableObject, SessionServicesInjecting {

    @Published
    var credential: Credential
    let visitedWebsite: String

    private let database: ApplicationDatabase
    private let autofillService: AutofillService
    private let domainLibrary: DomainIconLibrary
    private let teamSpacesService: TeamSpacesService
    private let sessionActivityReporter: ActivityReporterProtocol
    private let activityLogsService: ActivityLogsServiceProtocol
    private let completion: () -> Void

    init(credential: Credential,
         visitedWebsite: String,
         database: ApplicationDatabase,
         autofillService: AutofillService,
         domainLibrary: DomainIconLibrary,
         teamSpacesService: TeamSpacesService,
         sessionActivityReporter: ActivityReporterProtocol,
         activityLogsService: ActivityLogsServiceProtocol,
         completion: @escaping () -> Void) {
        self.credential = credential
        self.visitedWebsite = visitedWebsite
        self.database = database
        self.autofillService = autofillService
        self.domainLibrary = domainLibrary
        self.teamSpacesService = teamSpacesService
        self.sessionActivityReporter = sessionActivityReporter
        self.activityLogsService = activityLogsService
        self.completion = completion
    }

    func makeIconViewModel() -> VaultItemIconViewModel {
        VaultItemIconViewModel(item: credential, iconLibrary: domainLibrary)
    }

    func link() {
        credential.linkedServices.associatedDomains.append(LinkedServices.AssociatedDomain(domain: visitedWebsite, source: .remember))

                if let bussinessTeam = teamSpacesService.businessInfo.availableBusinessTeam, bussinessTeam.shouldBeForced(on: credential) {
            credential.spaceId = bussinessTeam.teamId
        }

        _ = try? database.save(credential)
        let logCredential = credential
        sessionActivityReporter.report(UserEvent.CallToAction(callToActionList: [.linkWebsite, .doNotLinkWebsite],
                                                              chosenAction: .linkWebsite,
                                                              hasChosenNoAction: false))

        sessionActivityReporter.report(UserEvent.UpdateVaultItem(action: .edit,
                                                                 fieldsEdited: [.associatedWebsitesList],
                                                                 itemId: logCredential.userTrackingLogID,
                                                                 itemType: .credential,
                                                                 space: logCredential.userTrackingSpace))

        sessionActivityReporter.report(AnonymousEvent.UpdateCredential(action: .edit,
                                                                       associatedWebsitesAddedList: [self.visitedWebsite.hashedDomainForLogs().id ?? ""],
                                                                       associatedWebsitesRemovedList: [],
                                                                       domain: logCredential.hashedDomainForLogs(),
                                                                       space: logCredential.userTrackingSpace))
        if let info = credential.reportableInfo() {
            try? activityLogsService.report(.update, for: info)
        }
        autofillService.saveNewCredentials([credential], completion: { _ in
            self.completion()
        })
    }

    func ignore() {
        sessionActivityReporter.report(UserEvent.CallToAction(callToActionList: [.linkWebsite, .doNotLinkWebsite],
                                                              chosenAction: .doNotLinkWebsite,
                                                              hasChosenNoAction: false))

        completion()
    }
}
