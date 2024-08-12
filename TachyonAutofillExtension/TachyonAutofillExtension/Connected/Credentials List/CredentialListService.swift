import AuthenticationServices
import AutofillKit
import Combine
import CorePersonalData
import CorePremium
import DomainParser
import Foundation
import VaultKit

@MainActor
class CredentialListService {
  @Published
  var allCredentials: [CorePersonalData.Credential] = []

  @Published
  var matchingPasskeys: [CorePersonalData.Passkey] = []

  @Published
  var isReady: Bool = false

  private let database: ApplicationDatabase
  private let domainParser: DomainParserProtocol
  private let request: CredentialsListRequest
  private var subscription: AnyCancellable?
  private let capabilityService: CapabilityServiceProtocol

  private var isPasswordLimitEnabled: Bool {
    capabilityService.capabilities[.passwordsLimit]?.enabled == true
  }

  private var limit: Int? {
    capabilityService.capabilities[.passwordsLimit]?.info?.limit
  }

  var hasPasswordLimitBeenReached: Bool {
    guard let limit = limit else { return false }
    return isPasswordLimitEnabled && self.allCredentials.count >= limit
  }

  var canAddPassword: Bool {
    if let capability = capabilityService.capabilities[.passwordsLimit],
      capability.enabled,
      let limit = capability.info?.limit,
      limit <= allCredentials.count
    {
      return false
    } else {
      return true
    }
  }

  init(
    syncStatusPublisher: AnyPublisher<SyncService.SyncStatus, Never>,
    userSpacesService: UserSpacesService,
    domainParser: DomainParserProtocol,
    database: ApplicationDatabase,
    capabilityService: CapabilityServiceProtocol,
    request: CredentialsListRequest
  ) {
    self.database = database
    self.domainParser = domainParser
    self.capabilityService = capabilityService
    self.request = request
    let credentialsPublisher = self.database.itemsPublisher(for: Credential.self)
    let passkeysPublisher = self.database.itemsPublisher(for: Passkey.self)

    subscription = credentialsPublisher.combineLatest(passkeysPublisher)
      .sink { [weak self] credentials, passkeys in
        guard let self else {
          return
        }

        self.allCredentials = credentials.filter {
          userSpacesService.configuration.virtualUserSpace(for: $0) != nil
        }
        if #available(iOS 17, *), case let .servicesAndPasskey(_, passkeyAssertionRequest) = request
        {
          self.matchingPasskeys =
            passkeys
            .filter(passkeyAssertionRequest.matches(passkey:))
            .filter { userSpacesService.configuration.virtualUserSpace(for: $0) != nil }
        }
        self.isReady = true
      }
  }

  func matchingCredentials(from allCredentials: [Credential]) -> [Credential] {
    guard let lastServiceIdentifier = self.request.services.last?.identifier,
      let host = URL(string: lastServiceIdentifier)?.host
    else {
      return []
    }
    let domain = self.domainParser.parse(host: host)?.domain
    return allCredentials.filter(onDomain: domain ?? host)
  }
}

extension PasskeyAssertionRequest {
  fileprivate func matches(passkey: Passkey) -> Bool {
    let isSameRelyingParty = passkey.relyingPartyId.rawValue == relyingPartyID
    if allowedCredentials.isEmpty {
      return isSameRelyingParty
    } else {
      let credentialId = passkey.credentialId.data(using: .utf8) ?? Data()
      return isSameRelyingParty && allowedCredentials.contains(credentialId)
    }
  }
}

extension Array where Element == Credential {
  fileprivate func filter(onDomain domain: String) -> [Element] {
    let lowercasedDomain = domain.lowercased()
    return filter { credential in
      let inAssociatedDomains =
        credential.url?.domain?.linkedDomains?.contains(where: { $0.contains(lowercasedDomain) })
        ?? false
      let inManualAssociatedDomains = credential.manualAssociatedDomains.contains(where: {
        $0.contains(lowercasedDomain)
      })
      return inAssociatedDomains || inManualAssociatedDomains
        || credential.editableURL.contains(lowercasedDomain)
    }
  }
}
