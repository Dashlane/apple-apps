import Foundation
import Combine
import AuthenticationServices
import CorePersonalData
import DashTypes

public class AutofillService {
        private let appExtensionCommunicationCenter: AppExtensionCommunicationCenter
        private let identityStore: IdentityStore
    private let queue = DispatchQueue(label: "AutofillServiceQueue", qos: .background)

    @Published
    public var activationStatus: AutofillActivationStatus = .unknown
    private var subscriptions: Set<AnyCancellable> = []

    public init<P: Publisher>(channel: AppExtensionCommunicationCenter.Channel, identityStore: IdentityStore = ASCredentialIdentityStore.shared, credentialsPublisher: P) where P.Output: Collection, P.Failure == Never, P.Output.Element == Credential {
        self.appExtensionCommunicationCenter = .init(channel: channel, baseURL: ApplicationGroup.documentsURL)
        self.identityStore = identityStore

                        NotificationCenter.default
            .willEnterForegroundNotificationPublisher()?
            .flatMap(identityStore.getState)
            .prepend(identityStore.getState(nil))
            .assign(to: \.activationStatus, on: self)
            .store(in: &subscriptions)

        let debouncedCredentialsPublisher = credentialsPublisher
            .combineLatest($activationStatus)
            .debounce(for: .milliseconds(500), scheduler: queue)

        debouncedCredentialsPublisher.sink { [weak self] credentials, activationStatus in
            guard activationStatus == .enabled else {
                return
            }
            self?.updateStore(using: credentials)
        }
        .store(in: &subscriptions)

    }

    public func unload() {
        subscriptions.forEach { $0.cancel() }
        clearIdentityStore()
                        appExtensionCommunicationCenter.write(message: .userDidLogout)
    }

    func updateStore<C: Collection>(using credentials: C) where C.Element == Credential {
        let credentialIdentities = credentials
            .sortedByLastUsage()
            .compactMap { $0.credentialIdentity.flatMap { $0 } }.flatMap { $0 }
        identityStore.replaceCredentialIdentities(with: credentialIdentities, completion: nil)
    }

    public func saveNewCredentials(_ newCredentials: [Credential], completion: @escaping (Result<Void, Error>) -> Void) {
        identityStore.getState { [weak self] state in
            guard let self = self else {
                completion(.failure(IdentityStoreError.couldNotRetrieveStoreStatus))
                return
            }
            guard state.isEnabled else {
                completion(.failure(IdentityStoreError.identityStoreStateIsDisabled))
                return
            }
            guard state.supportsIncrementalUpdates else {
                completion(.failure(IdentityStoreError.doesNotSupportIncrementalUpdate))
                return
            }
            let credentialIdentities = newCredentials
                .sortedByLastUsage()
                .compactMap { $0.credentialIdentity.flatMap { $0 } }
                .flatMap { $0 }
            self.identityStore.saveCredentialIdentities(credentialIdentities) { _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success)
                }
            }
        }
    }

    private func clearIdentityStore() {
        identityStore.removeAllCredentialIdentities(nil)
    }
}

public extension AutofillService {
    static var fakeService: AutofillService {
        .init(channel: .fromApp, credentialsPublisher: Just<[Credential]>([]).eraseToAnyPublisher())
    }
}

enum IdentityStoreError: Error {
    case doesNotSupportIncrementalUpdate
    case couldNotRetrieveStoreStatus
    case identityStoreStateIsDisabled
}

public protocol IdentityStore {
    func getState(_ completion: @escaping (ASCredentialIdentityStoreState) -> Void)
    func getState(_ notification: Notification?) -> AnyPublisher<AutofillActivationStatus, Never>
    func saveCredentialIdentities(_ credentialIdentities: [ASPasswordCredentialIdentity], completion: ((Bool, Error?) -> Void)?)
    func replaceCredentialIdentities(with newCredentialIdentities: [ASPasswordCredentialIdentity], completion: ((Bool, Error?) -> Void)?)
    func removeAllCredentialIdentities(_ completion: ((Bool, Error?) -> Void)?)
}

extension ASCredentialIdentityStore: IdentityStore {
    public func getState(_ notification: Notification? = nil) -> AnyPublisher<AutofillActivationStatus, Never> {
        return Future.init { completion in
            self.getState { storeState in
                completion(.success(storeState.isEnabled ? .enabled : .disabled))
            }
        }.eraseToAnyPublisher()
    }
}

private extension Credential {

                        var credentialIdentity: [ASPasswordCredentialIdentity]? {
                guard !self.subdomainOnly else {
            guard let host = self.url?.host else { return nil }

            let serviceIdentifier = ASCredentialServiceIdentifier(identifier: host, type: .domain)
            return [credentialIdentity(fromServiceIdentifier: serviceIdentifier,
                                      recordIdentifier: self.id.rawValue)]
        }

        guard let domain = self.url?.domain,
              !displayLogin.isEmpty,
              !password.isEmpty else {
                return nil
        }

                let serviceIdentifier = ASCredentialServiceIdentifier(identifier: domain.name, type: .domain)
        let identity = credentialIdentity(fromServiceIdentifier: serviceIdentifier,
                                          recordIdentifier: self.id.rawValue)

                guard !self.subdomainOnly else {
            return [identity]
        }

                var associatedDomains = Set<String>()
        if let classicAssociatedDomains = domain.linkedDomains {
            associatedDomains.formUnion(classicAssociatedDomains)
        }
        associatedDomains.formUnion(manualAssociatedDomains)

        var identities = associatedDomains.compactMap(self.credentialIdentity)

                let linkedServicesIdentities = linkedServices.associatedDomains.map { $0.domain }.compactMap(self.credentialIdentity)
        identities += linkedServicesIdentities

        if identities.count > 0 {
                        return identities
        } else {
            return [identity]
        }
    }

    private func credentialIdentity(fromDomain domain: String) -> ASPasswordCredentialIdentity {
        let serviceIdentifier = ASCredentialServiceIdentifier(identifier: domain, type: .domain)
        return credentialIdentity(fromServiceIdentifier: serviceIdentifier, recordIdentifier: self.id.rawValue)
    }

    private func credentialIdentity(fromServiceIdentifier serviceIdentifier: ASCredentialServiceIdentifier,
                                    recordIdentifier: String) -> ASPasswordCredentialIdentity {
        return ASPasswordCredentialIdentity(serviceIdentifier: serviceIdentifier,
                                            user: autofillTitle,
                                            recordIdentifier: recordIdentifier)
    }

        var autofillTitle: String {
        guard !title.isEmpty else {
            return displayLogin
        }
        return "\(title) – \(displayLogin)"
    }
}
