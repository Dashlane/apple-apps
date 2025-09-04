import Combine
import CoreTypes
import Foundation
import LogFoundation

protocol CredentialsServiceDelegate: AnyObject {
  func credentialsServiceDidUpdate()
  func breachesByPasswords() async -> BreachesByPasswords
}

public class CredentialsService {
  typealias CredentialsByBreachId = [String: [SecurityDashboardCredential]]
  @Published
  internal var cachedCredentials = [SecurityDashboardCredential]()
  @Published
  internal var cachedBreachCredentials = CredentialsByBreachId()

  var cachedBreachCredentialsPublisher: AnyPublisher<CredentialsByBreachId, Never> {
    $cachedBreachCredentials.eraseToAnyPublisher()
  }

  private let credentialsProvider: CredentialsProvider
  private let passwordsSimilarityOperation: PasswordsSimilarityOperation
  private let log: Logger
  private let queue: DispatchQueue

  weak var delegate: CredentialsServiceDelegate?

  init(
    credentialsProvider: CredentialsProvider,
    passwordsSimilarityOperation: PasswordsSimilarityOperation,
    queue: DispatchQueue,
    log: Logger
  ) {
    self.credentialsProvider = credentialsProvider
    self.passwordsSimilarityOperation = passwordsSimilarityOperation
    self.log = log
    self.queue = queue
    credentialsProvider.updater = self
  }

  func refreshCompromisedInCache() {
    queue.async {
      self.refreshCompromisedAndCache(self.cachedCredentials)
    }
  }

  private func refreshCompromisedAndCache(_ credentials: [SecurityDashboardCredential]) {
    assert(!Thread.isMainThread)
    Task {
      self.log.debug(
        "Starting to refresh compromised: previous count \(self.cachedCredentials.count)")
      (self.cachedCredentials, self.cachedBreachCredentials) = await self.refreshCompromised(
        on: credentials)

      self.log.debug("Did refresh compromised: new count \(self.cachedCredentials.count)")
      self.delegate?.credentialsServiceDidUpdate()
    }
  }

  private func refreshCompromised(on credentials: [SecurityDashboardCredential]) async -> (
    [SecurityDashboardCredential], CredentialsByBreachId
  ) {
    let breachesByPasswords = await self.delegate?.breachesByPasswords() ?? [:]

    return await passwordsSimilarityOperation.run { passwordsSimilarity in
      var credentialsBreachesMap = CredentialsByBreachId()
      var newCredentials = [SecurityDashboardCredential]()

      for var credential in credentials {
        let breaches =
          breachesByPasswords
          .filter { passwordsSimilarity.is($0.key, equivalentTo: credential.password) }
          .flatMap { $0.value }

        credential.compromisedIn =
          breaches
          .compactMap(DashboardBreach.init)

        newCredentials.append(credential)

        for breach in breaches {
          credentialsBreachesMap[breach.id, default: []].append(credential)
        }
      }

      return (newCredentials, credentialsBreachesMap)
    }
  }

  func isCredentialCompromised(credentialID: String, onCompletion: @escaping (Bool) -> Void) {
    self.queue.async { [weak self] in
      guard let credential = self?.cachedCredentials.first(where: { $0.identifier == credentialID })
      else {
        DispatchQueue.main.async {
          onCompletion(false)
        }
        return
      }
      DispatchQueue.main.async {
        onCompletion(!credential.compromisedIn.isEmpty)
      }
    }
  }
}

extension CredentialsService {
  func compromisedCredentials() -> Future<[String], Never> {
    Future<[String], Never> { [weak self] promise in
      self?.queue.async {
        guard let cachedCredentials = self?.cachedCredentials else {
          DispatchQueue.main.async {
            promise(.success([]))
          }
          return
        }
        promise(
          .success(cachedCredentials.filter { !$0.compromisedIn.isEmpty }.map { $0.identifier }))
      }
    }
  }
}

extension CredentialsService: IdentityDashboardCredentialsUpdates {
  public func refreshCredentials() {
    self.queue.async {
      let credentials = self.credentialsProvider.fetchCredentials()
      self.refreshCompromisedAndCache(credentials)
    }
  }

  func isCredentialCompromised(credentialID: String) -> Bool {
    guard let credential = cachedCredentials.first(where: { $0.identifier == credentialID }) else {
      return false
    }
    return !credential.compromisedIn.isEmpty
  }

}
