import AuthenticationServices
import AutofillKit
import Combine
import CorePersonalData
import CorePremium
import DomainParser
import Foundation
import VaultKit

@MainActor
class CredentialListItemsProvider {
  struct ItemsContainer {
    let suggested: [VaultItem]
    let all: [VaultItem]
  }

  @Published
  var items: ItemsContainer?

  private let database: ApplicationDatabase
  private let domainParser: DomainParserProtocol
  private let request: CredentialsListRequest
  private var subscription: AnyCancellable?
  private let userSpacesService: UserSpacesService
  private let queue = DispatchQueue(label: "items provider", qos: .userInitiated)

  init(
    syncStatusPublisher: AnyPublisher<SyncService.SyncStatus, Never>,
    userSpacesService: UserSpacesService,
    domainParser: DomainParserProtocol,
    database: ApplicationDatabase,
    request: CredentialsListRequest
  ) {
    self.database = database
    self.domainParser = domainParser
    self.userSpacesService = userSpacesService
    self.request = request

    setup()
  }

  private func setup() {
    switch request.type {
    case .passwords:
      database.itemsPublisher(for: Credential.self)
        .receive(on: queue)
        .compactMap { [weak self] credentials in
          guard let self else {
            return nil
          }

          let credentials = credentials.filter {
            self.userSpacesService.configuration.virtualUserSpace(for: $0) != nil
          }

          return self.items(with: credentials)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$items)

    case .otps:
      database.itemsPublisher(for: Credential.self)
        .receive(on: queue)
        .compactMap { [weak self] credentials in
          guard let self else {
            return nil
          }
          let credentials = credentials.filter {
            $0.otpURL != nil
              && self.userSpacesService.configuration.virtualUserSpace(for: $0) != nil
          }

          return self.items(with: credentials)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$items)

    case .passkeysAndPasswords(let passkeyAssertionRequest):
      database.itemsPublisher(for: Passkey.self)
        .combineLatest(database.itemsPublisher(for: Credential.self))
        .receive(on: queue)
        .compactMap { [weak self] passkeys, credentials in
          guard let self else {
            return nil
          }

          let credentials = credentials.filter {
            self.userSpacesService.configuration.virtualUserSpace(for: $0) != nil
          }

          let suggestedPasskeys = passkeys.filter { passkey in
            self.userSpacesService.configuration.virtualUserSpace(for: passkey) != nil
              && passkeyAssertionRequest.matches(passkey: passkey)
          }

          let suggestedItems: [any VaultItem] =
            suggestedPasskeys + self.matchingCredentials(from: credentials)

          return .init(suggested: suggestedItems, all: credentials)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$items)
    }
  }

  private func items(with credentials: [Credential]) -> ItemsContainer {
    return ItemsContainer(suggested: suggestedItems(for: credentials), all: credentials)
  }

  private func suggestedItems(for credentials: [Credential]) -> [Credential] {
    if credentials.count > 6 {
      return matchingCredentials(from: credentials)
    } else {
      return []
    }
  }

  private func matchingCredentials(from allCredentials: some Collection<Credential>) -> [Credential]
  {
    let domains = Set<String>(
      self.request.servicesIdentifiers.compactMap { serviceIdentifier in
        switch serviceIdentifier.type {
        case .URL:
          guard let host = URL(string: serviceIdentifier.identifier)?.host() else {
            return nil
          }

          return domainParser.parse(host: host)?.domain?.lowercased()

        case .domain:
          return serviceIdentifier.identifier.lowercased()
        @unknown default:
          return serviceIdentifier.identifier.lowercased()
        }
      })

    return allCredentials.filter(withDomains: domains)
  }
}

extension PasskeyAssertionRequest {
  fileprivate func matches(passkey: Passkey) -> Bool {
    let isSameRelyingParty = passkey.relyingPartyId.rawValue == relyingPartyIdentifier
    if allowedCredentials.isEmpty {
      return isSameRelyingParty
    } else {
      let credentialId = passkey.credentialId.data(using: .utf8) ?? Data()
      return isSameRelyingParty && allowedCredentials.contains(credentialId)
    }
  }
}

extension Collection where Element == Credential {
  fileprivate func filter(withDomains domains: Set<String>) -> [Element] {
    return filter { credential in
      let credentialDomains = credential.allDomains()
      return credentialDomains.contains {
        domains.contains($0)
      }
    }
  }
}

extension CredentialListItemsProvider {
  static var mock: CredentialListItemsProvider {
    CredentialListItemsProvider(
      syncStatusPublisher: PassthroughSubject().eraseToAnyPublisher(),
      userSpacesService: .mock(),
      domainParser: FakeDomainParser(),
      database: .mock(),
      request: .init(
        servicesIdentifiers: [
          ASCredentialServiceIdentifier(identifier: "amazon.com", type: .domain)
        ], type: .passwords))
  }
}
