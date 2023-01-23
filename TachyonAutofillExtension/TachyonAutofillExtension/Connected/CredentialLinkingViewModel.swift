import Foundation
import VaultKit
import CorePersonalData
import CoreUserTracking
import CorePremium
import IconLibrary

final class CredentialLinkingViewModel: ObservableObject {

    @Published
    var credential: Credential
    let visitedWebsite: String

    private let database: ApplicationDatabase
    private let autofillService: AutofillService
    private let domainLibrary: DomainIconLibrary
    private let teamSpacesService: TeamSpacesService
    private let sessionActivityReporter: ActivityReporterProtocol
    private let completion: () -> Void

    init(credential: Credential,
         visitedWebsite: String,
         database: ApplicationDatabase,
         autofillService: AutofillService,
         domainLibrary: DomainIconLibrary,
         teamSpacesService: TeamSpacesService,
         sessionActivityReporter: ActivityReporterProtocol,
         completion: @escaping () -> Void) {
        self.credential = credential
        self.visitedWebsite = visitedWebsite
        self.database = database
        self.autofillService = autofillService
        self.domainLibrary = domainLibrary
        self.teamSpacesService = teamSpacesService
        self.sessionActivityReporter = sessionActivityReporter
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

        sessionActivityReporter.report(UserEvent.CallToAction(callToActionList: [.linkWebsite, .doNotLinkWebsite],
                                                              chosenAction: .linkWebsite,
                                                              hasChosenNoAction: false))

        sessionActivityReporter.report(UserEvent.UpdateVaultItem(action: .edit,
                                                                 fieldsEdited: [.associatedWebsitesList],
                                                                 itemId: credential.userTrackingLogID,
                                                                 itemType: .credential,
                                                                 space: credential.userTrackingSpace))

        sessionActivityReporter.report(AnonymousEvent.UpdateCredential(action: .edit,
                                                                       associatedWebsitesAddedList: [self.visitedWebsite.hashedDomainForLogs.id ?? ""],
                                                                       associatedWebsitesRemovedList: [],
                                                                       domain: credential.hashedDomainForLogs,
                                                                       space: credential.userTrackingSpace))

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
