import Foundation
import Combine
import CorePersonalData
import DomainParser
import AuthenticationServices
import CorePremium
import DashlaneAppKit

class CredentialListService {
    @Published
    var allCredentials: [CorePersonalData.Credential] = [] {
        didSet {
            self.isReady = true
        }
    }

        @Published
    var isReady: Bool = false
        
    private let database: ApplicationDatabase
    private let domainParser: DomainParser
    private let teamSpaceService: TeamSpacesService
    private let serviceIdentifiers: [ASCredentialServiceIdentifier]
    private var subscription: AnyCancellable?
    private let premiumStatus: PremiumStatus?
    
    private var isPasswordLimitEnabled: Bool {
        guard let premiumStatus = self.premiumStatus else {
            return false
        }
        return premiumStatus.capabilities.passwordsLimit.enabled
    }
    
    private var limit: Int? {
        return premiumStatus?.capabilities.passwordsLimit.info?.limit
    }
    
    var hasPasswordLimitBeenReached: Bool {
        guard let limit = limit else { return false }
        return isPasswordLimitEnabled && self.allCredentials.count >= limit
    }
    
    var canAddPassword: Bool {
        if let status = premiumStatus,
           status.capabilities.passwordsLimit.enabled,
           let limit = status.capabilities.passwordsLimit.info?.limit,
           limit <= allCredentials.count {
            return false
        }
        return true
    }
    
    init(syncStatusPublisher: AnyPublisher<SyncService.SyncStatus, Never>,
         teamSpaceService: TeamSpacesService,
         domainParser: DomainParser,
         database: ApplicationDatabase,
         premiumStatus: PremiumStatus?,
         serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        self.database = database
        self.domainParser = domainParser
        self.premiumStatus = premiumStatus
        self.teamSpaceService = teamSpaceService
        self.serviceIdentifiers = serviceIdentifiers
        subscription = self.database
            .itemsPublisher(for: Credential.self)
            .map { credentials in
                credentials.filter(self.teamSpaceService.shouldDisplay)
            }.assign(to:  \.allCredentials, on: self)
    }

                func matchingCredentials(from allCredentials: [Credential]) -> [Credential] {
        guard let lastServiceIdentifier = self.serviceIdentifiers.last?.identifier,
              let host = URL(string: lastServiceIdentifier)?.host else {
                  return []
              }
        let domain = self.domainParser.parse(host: host)?.domain
        return allCredentials.filter(onDomain: domain ?? host)
    }
}

private extension Array where Element == Credential {
    func filter(onDomain domain: String) -> [Element] {
        let lowercasedDomain = domain.lowercased()
        return filter { credential in
            let inAssociatedDomains = credential.url?.domain?.linkedDomains?.contains(where: { $0.contains(lowercasedDomain) }) ?? false
            let inManualAssociatedDomains = credential.manualAssociatedDomains.contains(where: { $0.contains(lowercasedDomain) })
            return inAssociatedDomains || inManualAssociatedDomains || credential.editableURL.contains(lowercasedDomain)
        }
    }
}
