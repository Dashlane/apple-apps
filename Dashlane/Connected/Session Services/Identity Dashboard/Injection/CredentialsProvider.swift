import Combine
import CoreCategorizer
import CorePasswords
import CorePersonalData
import CoreTypes
import DomainParser
import Foundation
import LogFoundation
import SecurityDashboard
import SwiftTreats
import VaultKit

class CredentialsProvider: SecurityDashboard.CredentialsProvider {
  weak var updater: IdentityDashboardCredentialsUpdates?

  private let queue = DispatchQueue(label: "IdentityDashboardCredentialsProvider", qos: .background)
  private let vaultItemsStore: VaultItemsStore
  private let passwordEvaluator: PasswordEvaluatorProtocol
  private let domainParser: DomainParserProtocol
  private let categorizer: Categorizer
  private var cancellable: AnyCancellable?

  @Atomic
  private var passwordStrengthCache: [String: SecurityDashboard.PasswordStrength] = [:]
  @Atomic
  private var domainIsSensitiveCache: [String: Bool] = [:]

  init(
    vaultItemsStore: VaultItemsStore,
    passwordEvaluator: PasswordEvaluatorProtocol,
    domainParser: DomainParserProtocol,
    categorizer: Categorizer
  ) {
    self.vaultItemsStore = vaultItemsStore
    self.passwordEvaluator = passwordEvaluator
    self.domainParser = domainParser
    self.categorizer = categorizer

    guard !SafeMode.isEnabled else {
      return
    }

    cancellable = vaultItemsStore
      .$credentials
      .debounce(for: .milliseconds(400), scheduler: queue)
      .removeDuplicates()
      .sink { [weak self] _ in
        self?.updater?.refreshCredentials()
      }
  }

  private func evaluate(_ credential: Credential) -> SecurityDashboard.PasswordStrength {
    if let passwordStrengthCache = passwordStrengthCache[credential.password] {
      return passwordStrengthCache
    } else {
      let strength = passwordEvaluator.evaluate(credential.password).identityDashboardStrength
      passwordStrengthCache[credential.password] = strength
      return strength
    }
  }

  private func isSensitiveDomain(for credential: Credential) -> Bool {
    guard let domain = credential.url?.domain?.name else {
      return false
    }

    if let isSensitiveDomain = domainIsSensitiveCache[domain] {
      return isSensitiveDomain
    } else {
      let isSensitiveDomain = categorizer.categorize(credential)?.important == true
      self.domainIsSensitiveCache[domain] = isSensitiveDomain
      return isSensitiveDomain
    }
  }

  func fetchCredentials() -> [SecurityDashboardCredential] {
    return vaultItemsStore.credentials
      .compactMap { credential in
        guard !credential.password.isEmpty else {
          return nil
        }

        let strength = self.evaluate(credential)
        let isSensitiveDomain = self.isSensitiveDomain(for: credential)

        return SecurityDashboardCredentialImplementation(
          credential: credential,
          strength: strength,
          isSensitiveDomain: isSensitiveDomain)
      }
  }
}

struct SecurityDashboardCredentialImplementation: SecurityDashboardCredential {
  let credential: Credential
  let spaceId: String
  let identifier: String
  let password: String
  let strength: SecurityDashboard.PasswordStrength
  let domain: String?

  var sensitiveDomain: Bool
  var disabledForPasswordAnalysis: Bool

  var compromisedIn = [SecurityDashboardBreach]()

  let lastModificationDate: Date
  let title: String
  let email: String?
  let username: String?

  init(
    credential: Credential, strength: SecurityDashboard.PasswordStrength, isSensitiveDomain: Bool
  ) {
    self.credential = credential
    self.spaceId = credential.spaceId ?? ""
    self.identifier = credential.id.rawValue
    self.password = credential.password
    self.strength = strength

    self.domain = credential.url?.domain?.name

    self.title = credential.title
    self.email = credential.email
    self.username = credential.login

    self.lastModificationDate =
      credential.passwordModificationDate ?? credential.userModificationDatetime ?? credential
      .creationDatetime ?? Date()

    self.sensitiveDomain = isSensitiveDomain

    self.disabledForPasswordAnalysis = credential.disabledForPasswordAnalysis
  }
}

extension CorePasswords.PasswordStrength {
  var identityDashboardStrength: SecurityDashboard.PasswordStrength {
    switch self {
    case .tooGuessable:
      return .veryUnsafe
    case .veryGuessable:
      return .unsafe
    case .somewhatGuessable:
      return .notSoSafe
    case .safelyUnguessable:
      return .safe
    case .veryUnguessable:
      return .superSafe
    }
  }
}
