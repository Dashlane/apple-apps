import Foundation
import DashlaneAppKit
import CorePersonalData
import Combine
import CoreUserTracking
import Network

class CredentialDomainsViewModel {
    var item: Credential
    let linkedDomains: [String]
    let canAddDomain: Bool
    let isAdditionMode: Bool
    let initialMode: DetailMode
    private let vaultItemsServices: VaultItemsServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let linkedDomainsService: LinkedDomainService
    private let updatePublisher: PassthroughSubject<CredentialDetailViewModel.LinkedServicesUpdate, Never>

    init(item: Credential,
         isAdditionMode: Bool,
         initialMode: DetailMode,
         vaultItemsServices: VaultItemsServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         linkedDomainsService: LinkedDomainService,
         updatePublisher: PassthroughSubject<CredentialDetailViewModel.LinkedServicesUpdate, Never>) {
        self.item = item
        self.isAdditionMode = isAdditionMode
        self.initialMode = initialMode
        self.canAddDomain = item.canAddDomain
        self.vaultItemsServices = vaultItemsServices
        self.activityReporter = activityReporter
        self.linkedDomainsService = linkedDomainsService
        self.updatePublisher = updatePublisher

        if let domain = item.url?.domain {
            linkedDomains = linkedDomainsService[domain.name] ?? []
        } else {
            linkedDomains = []
        }
    }

    func commit(addedDomains: LinkedServices) {
        updatePublisher.send(.commit(addedDomains: addedDomains))
    }

    func save(addedDomains: LinkedServices) {
        updatePublisher.send(.save(addedDomains: addedDomains))
    }

        private lazy var credentialDomainsPairs: [(credential: Credential, domain: String)] = Array(vaultItemsServices.credentials.map({ credential -> [(credential: Credential, domain: String)] in
        guard credential != self.item else {
            return []
        }

                let urls = credential.allDomains(using: linkedDomainsService)

        return  urls.map { (credential: credential, domain: $0.lowercased()) }
    }).joined())

        func hasDuplicate(for domain: String) -> Credential? {
        guard let createdUrl = domain.openableURL?.host?.lowercased() else {
            return nil
        }

        for keyPair in credentialDomainsPairs where keyPair.domain == createdUrl {
            return keyPair.credential
        }

        return nil
    }
}

extension CredentialDomainsViewModel {
    static var mock: CredentialDomainsViewModel {
        CredentialDomainsViewModel(item: PersonalDataMock.Credentials.amazon,
                                   isAdditionMode: false,
                                   initialMode: .viewing,
                                   vaultItemsServices: MockServicesContainer().vaultItemsService,
                                   activityReporter: .fake,
                                   linkedDomainsService: MockServicesContainer().linkedDomainService,
                                   updatePublisher: PassthroughSubject<CredentialDetailViewModel.LinkedServicesUpdate, Never>())
    }
}

extension Credential {
    var canAddDomain: Bool {
        return !metadata.isShared || metadata.sharingPermission != .limited
    }
}
