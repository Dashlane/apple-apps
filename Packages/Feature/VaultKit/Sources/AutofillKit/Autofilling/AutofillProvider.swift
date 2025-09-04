import AuthenticationServices
import CorePersonalData
import CorePremium
import CoreTeamAuditLogs
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import TOTPGenerator
import UserTrackingFoundation
import VaultKit

@MainActor
public struct AutofillProvider {

  @Loggable
  public enum Error: Swift.Error {
    case couldNotFindCredential
    case couldNotFindOTPCode
  }

  let hasUserBeenVerified: Bool
  let createPasskeyOnCloud: Bool
  let database: ApplicationDatabase
  let otpNotificationSender: (Credential) -> Void
  let context: CredentialProviderContext
  let logger: AutofillProviderLogger
  let teamAuditLogsService: TeamAuditLogsServiceProtocol
  let userSpacesService: UserSpacesService
  let autofillService: AutofillStateServiceProtocol
  let localWebAuthnAuthenticator: LocalWebAuthnAuthenticator
  let cloudWebAuthnAuthenticator: CloudWebAuthnAuthenticator

  public init(
    hasUserBeenVerified: Bool,
    createPasskeyOnCloud: Bool = true,
    database: ApplicationDatabase,
    applicationReporter: ActivityReporterProtocol,
    sessionReporter: ActivityReporterProtocol,
    userSpacesService: UserSpacesService,
    autofillService: AutofillStateServiceProtocol,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    cloudPasskeyAPIClient: UserSecureNitroEncryptionAPIClient.Passkeys,
    otpNotificationSender: @escaping (Credential) -> Void,
    logger: Logger,
    context: CredentialProviderContext
  ) {
    self.hasUserBeenVerified = hasUserBeenVerified
    self.createPasskeyOnCloud = createPasskeyOnCloud
    self.database = database
    self.logger = AutofillProviderLogger(
      applicationReporter: applicationReporter,
      sessionReporter: sessionReporter)
    self.otpNotificationSender = otpNotificationSender
    self.context = context
    self.userSpacesService = userSpacesService
    self.autofillService = autofillService
    self.teamAuditLogsService = teamAuditLogsService
    self.localWebAuthnAuthenticator = LocalWebAuthnAuthenticator(
      hasUserBeenVerified: hasUserBeenVerified)
    self.cloudWebAuthnAuthenticator = CloudWebAuthnAuthenticator(
      client: cloudPasskeyAPIClient,
      hasUserBeenVerified: hasUserBeenVerified,
      logger: logger)
  }

  public func cancel() {
    context.cancelRequest(withError: NSError(.userCanceled))
  }
}

extension AutofillProvider {
  public func autofillPassword(for credentialIdentity: ASPasswordCredentialIdentity) async throws {
    try await withCheckedThrowingContinuation { continuation in
      do {
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

        context.completeRequest(
          withSelectedCredential: ASPasswordCredential(credential: credential)
        ) { _ in
          continuation.resume()
          teamAuditLogsService.logAutofillCredential(credential, autofilledDomain: visitedWebsite)
        }
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }

  public func autofillPassword(with credential: Credential, on visitedWebsite: String?) {
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
      teamAuditLogsService.logAutofillCredential(credential, autofilledDomain: visitedWebsite ?? "")
    }
  }
}

extension AutofillProvider {
  public func autofillPasskey(for passkeyRequest: ASPasskeyCredentialRequest) async throws {
    do {
      let passkeys = try database.fetchAll(Passkey.self)
      guard let passkey = passkeys.first(for: passkeyRequest) else {
        throw Error.couldNotFindCredential
      }

      await autofill(passkey, for: passkeyRequest)

      logger.asserted(passkey, for: passkeyRequest)
    } catch {
      logger.failedAssertion(for: passkeyRequest)
      throw error
    }
  }

  public func autofill(_ passkey: Passkey, for passkeyRequest: PasskeyAssertionRequest) async {
    do {
      let credential =
        switch try passkey.mode {
        case let .cloud(key):
          try await cloudWebAuthnAuthenticator.assert(passkeyRequest, using: passkey, key: key)
        case let .local(key):
          try await localWebAuthnAuthenticator.assert(passkeyRequest, using: passkey, key: key)
        }

      try database.updateLastUseDate(for: [passkey.id], origin: [.default])

      _ = await context.completeAssertionRequest(using: credential)

      teamAuditLogsService.logPasskeyLogin(
        passkey, currentDomain: passkeyRequest.relyingPartyIdentifier,
        credentialLogin: passkey.userDisplayName)
    } catch {
      logger.failedAssertion(of: passkey, for: passkeyRequest)
      context.cancelRequest(withError: NSError(.failed))
    }
  }

  public func registerPasskey(
    for passkeyRequest: ASPasskeyCredentialRequest, syncService: SyncServiceProtocol
  ) async throws {
    do {
      let authenticator: any WebAuthnAuthenticator =
        if createPasskeyOnCloud {
          cloudWebAuthnAuthenticator
        } else {
          localWebAuthnAuthenticator
        }
      let output = try await authenticator.register(for: passkeyRequest)

      var passkey = output.createdPasskey
      passkey.spaceId = userSpacesService.configuration.defaultSpace(for: passkey).personalDataId
      passkey = try database.save(passkey)

      syncService.sync(triggeredBy: .save)

      await autofillService.save(passkey, oldPasskey: nil)
      logger.registered(passkey, for: passkeyRequest)

      _ = await context.completeRegistrationRequest(using: output.registrationCredential)
    } catch {
      logger.failedRegistration(
        for: passkeyRequest, passkeyType: createPasskeyOnCloud ? .cloud : .legacy)
      throw error
    }
  }
}

extension AutofillProvider {
  @available(iOS 18.0, macOS 15, visionOS 2.0, *)
  public func autofillOTPCredential(for credentialIdentity: ASOneTimeCodeCredentialIdentity)
    async throws
  {
    guard let id = credentialIdentity.recordIdentifier,
      let credential = try? database.fetch(with: Identifier(id), type: Credential.self)
    else {
      throw Error.couldNotFindCredential
    }

    let visitedWebsite = credentialIdentity.serviceIdentifier.identifier

    logger.autofilled(
      credential,
      requiredUserSelection: false,
      matchType: credential.matchType(forWebsite: visitedWebsite),
      isOTP: true)

    try? database.updateLastUseDate(for: [credential.id], origin: [.default])

    try await performAutofillOTPCredential(with: credential)
  }

  @available(iOS 18.0, macOS 15, *)
  private func performAutofillOTPCredential(with credential: Credential) async throws {
    guard let url = credential.otpURL, let otp = try? OTPConfiguration(otpURL: url) else {
      throw Error.couldNotFindOTPCode
    }

    let code = otp.generate()
    _ = await context.completeOneTimeCodeRequest(using: ASOneTimeCodeCredential(code: code))
  }

  @available(iOS 18.0, macOS 15, *)
  public func autofillOTPCredential(with credential: Credential) async {
    do {
      logger.autofilled(
        credential,
        requiredUserSelection: true,
        matchType: .explorePasswords,
        isOTP: true)
      try await performAutofillOTPCredential(with: credential)
    } catch {
      context.cancelRequest(withError: NSError(.failed))
    }
  }

}

extension AutofillProvider {

  @available(iOS 18.0, *)
  @available(macCatalyst, unavailable)
  @available(visionOS, unavailable)
  public func autofillText(with vaultItem: VaultItem, _ text: String) async {
    try? database.updateLastUseDate(for: [vaultItem.id], origin: [.default])
    logger.autofilledFromContextMenu(vaultItem)
    #if !targetEnvironment(macCatalyst) && !os(visionOS)
      _ = await context.completeRequest(withTextToInsert: text)
    #endif
  }
}

extension Credential {
  fileprivate func matchType(forWebsite website: String) -> Definition.MatchType {
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

extension NSError {
  public convenience init(_ code: ASExtensionError.Code) {
    self.init(domain: ASExtensionErrorDomain, code: code.rawValue)
  }
}
