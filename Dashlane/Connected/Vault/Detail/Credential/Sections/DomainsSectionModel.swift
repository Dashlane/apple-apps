import CorePersonalData
import CoreUserTracking
import DashlaneAppKit
import DashTypes
import Foundation
import SwiftUI
import VaultKit

class DomainsSectionModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    let logger: CredentialDetailUsageLogger

    var canAddDomain: Bool {
        !hasLimitedRights
    }

    var addedDomains: [LinkedServices.AssociatedDomain] {
        return item.linkedServices.associatedDomains
    }

    var linkedDomains: [String] {
        guard let domain = item.url?.domain, let linkedDomains = linkedDomainsService[domain.name] else {
            return []
        }
        return linkedDomains
    }

    var linkedDomainsCount: Int {
        return linkedDomains.count + addedDomains.count
    }

    let service: DetailService<Credential>

    private var activityReporter: ActivityReporterProtocol {
        service.activityReporter
    }
    private var sharingService: SharedVaultHandling {
        service.sharingService
    }

    private let linkedDomainsService: LinkedDomainService

    init(
        service: DetailService<Credential>,
        linkedDomainsService: LinkedDomainService
    ) {
        self.service = service
        self.logger = CredentialDetailUsageLogger(usageLogService: service.usageLogService, item: service.item)
        self.linkedDomainsService = linkedDomainsService
    }

    func logOpenUrl() {
        activityReporter.report(UserEvent.OpenExternalVaultItemLink(
            domainType: .web,
            itemId: item.userTrackingLogID,
            itemType: .credential)
        )
        activityReporter.report(AnonymousEvent.OpenExternalVaultItemLink(
            domain: item.hashedDomainForLogs,
            itemType: .credential)
        )
    }
}

extension DomainsSectionModel {
    static func mock(
        service: DetailService<Credential>
    ) -> DomainsSectionModel {
        DomainsSectionModel(
            service: service,
            linkedDomainsService: LinkedDomainService()
        )
    }
}
