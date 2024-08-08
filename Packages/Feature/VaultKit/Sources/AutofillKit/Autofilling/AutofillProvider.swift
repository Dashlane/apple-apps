import AuthenticationServices
import CorePersonalData
import CorePremium
import CoreUserTracking
import DashTypes
import Foundation
import TOTPGenerator
import VaultKit

@MainActor
public struct AutofillProvider {

  public enum Error: Swift.Error {
    case couldNotFindCredential
  }

  let hasUserBeenVerified: Bool
  let database: ApplicationDatabase
  let otpNotificationSender: (Credential) -> Void
  let context: CredentialProviderContext
  let logger: AutofillProviderLogger
  let userSpacesService: UserSpacesService
  let autofillService: AutofillService

  public init(
    hasUserBeenVerified: Bool,
    database: ApplicationDatabase,
    applicationReporter: ActivityReporterProtocol,
    sessionReporter: ActivityReporterProtocol,
    userSpacesService: UserSpacesService,
    autofillService: AutofillService,
    otpNotificationSender: @escaping (Credential) -> Void,
    context: CredentialProviderContext
  ) {
    self.hasUserBeenVerified = hasUserBeenVerified
    self.database = database
    self.logger = AutofillProviderLogger(
      applicationReporter: applicationReporter,
      sessionReporter: sessionReporter)
    self.otpNotificationSender = otpNotificationSender
    self.context = context
    self.userSpacesService = userSpacesService
    self.autofillService = autofillService
  }

  public func autofillPasswordCredential(for credentialIdentity: ASPasswordCredentialIdentity)
    throws
  {
    guard let id = credentialIdentity.recordIdentifier,
      let credential = try? database.fetch(with: Identifier(id), type: Credential.self)
    else {
      throw Error.couldNotFindCredential
    }
    let visitedWebsite = credentialIdentity.serviceIdentifier.identifier

    otpNotificationSender(credential)

    logger.autofilled(
      credential,
      requiredUserSelection: false,
      matchType: credential.matchType(forWebsite: visitedWebsite))

    try? database.updateLastUseDate(for: [credential.id], origin: [.default])

    context.completeRequest(withSelectedCredential: ASPasswordCredential(credential: credential)) {
      _ in
    }
  }

  public func autofillPasswordCredential(for credential: Credential, on visitedWebsite: String?) {
    if let visitedWebsite {
      otpNotificationSender(credential)
      logger.autofilled(
        credential,
        requiredUserSelection: true,
        matchType: credential.matchType(forWebsite: visitedWebsite))
    }
    try? database.updateLastUseDate(for: [credential.id], origin: [.default])
    context.completeRequest(withSelectedCredential: ASPasswordCredential(credential: credential)) {
      _ in
    }
  }

  @available(iOS 17.0, macOS 14, *)
  public func autofillPasskey(for passkeyRequest: ASPasskeyCredentialRequest) async throws {

    do {
      let authenticator = makeWebAuthnAuthenticator()
      let (credential, passkey) = try authenticator.authenticate(passkeyRequest)
      logger.asserted(passkey: passkey, passkeyRequest: passkeyRequest)
      _ = await context.completeAssertionRequest(using: credential)
    } catch {
      logger.failedAssertion(for: passkeyRequest)
      throw error
    }
  }

  @available(iOS 17.0, macOS 14, *)
  public func autofill(_ passkey: Passkey, for passkeyRequest: PasskeyAssertionRequest) async throws
  {
    let authenticator = makeWebAuthnAuthenticator()
    let credential = try authenticator.assert(passkey, for: passkeyRequest)
    _ = await context.completeAssertionRequest(using: credential)
  }

  @available(iOS 17.0, macOS 14, *)
  public func savePasskey(
    for passkeyRequest: ASPasskeyCredentialRequest,
    syncService: SyncServiceProtocol
  ) async throws {
    let authenticator = makeWebAuthnAuthenticator()
    let (generatedCredential, passkey) = try await authenticator.create(passkeyRequest)
    syncService.sync(triggeredBy: .save)
    logger.registered(passkey: passkey, passkeyRequest: passkeyRequest)
    _ = await context.completeRegistrationRequest(using: generatedCredential)
  }
  @available(iOS 17.0, macOS 14, *)
  private func makeWebAuthnAuthenticator() -> WebAuthnAuthenticator {
    WebAuthnAuthenticator(
      hasUserBeenVerified: hasUserBeenVerified,
      database: database,
      userSpacesService: userSpacesService,
      autofillService: autofillService)
  }
}

extension Credential {
  fileprivate func matchType(forWebsite website: String) -> Definition.MatchType {
    if manualAssociatedDomains.contains(website) {
      return .remembered
    }

    if let associatedDomains = url?.domain?.linkedDomains {
      for associatedDomain in associatedDomains where website.contains(associatedDomain) {
        return .associatedWebsite
      }
    }

    for linkedService in linkedServices.associatedDomains
    where website.contains(linkedService.domain) {
      switch linkedService.source {
      case .remember: return .remembered
      case .manual: return .userAssociatedWebsite
      }
    }

    return .regular
  }
}

extension ASPasswordCredential {
  fileprivate convenience init(credential: Credential) {
    self.init(user: credential.displayLogin, password: credential.password)
  }
}
