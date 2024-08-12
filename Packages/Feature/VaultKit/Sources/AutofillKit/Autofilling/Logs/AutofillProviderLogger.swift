import AuthenticationServices
import CorePersonalData
import CoreUserTracking
import CryptoKit
import DashTypes
import Foundation

struct AutofillProviderLogger {

  let applicationReporter: ActivityReporterProtocol
  let sessionReporter: ActivityReporterProtocol

  func autofilled(
    _ credential: Credential,
    requiredUserSelection: Bool,
    matchType: Definition.MatchType
  ) {
    let isBusinessSpace = (credential.spaceId ?? "").isEmpty ? false : true
    let event = UserEvent.PerformAutofill(
      autofillMechanism: .iosTachyon,
      autofillOrigin: .automatic,
      fieldsFilled: .init(credential: 1),
      formTypeList: [.login],
      isAutologin: false,
      isManual: requiredUserSelection,
      matchType: matchType,
      space: isBusinessSpace ? .professional : .personal)
    sessionReporter.report(event)

    applicationReporter.report(
      AnonymousEvent.PerformAutofill(
        autofillMechanism: .iosTachyon,
        autofillOrigin: .automatic,
        domain: credential.hashedDomainForLogs(),
        formTypeList: [.login],
        isAutologin: false,
        isManual: true,
        isNativeApp: true,
        matchType: matchType))
  }

  @available(iOS 17.0, macOS 14, *)
  func asserted(
    passkey: Passkey,
    passkeyRequest: ASPasskeyCredentialRequest
  ) {
    let isBusinessSpace = (passkey.spaceId ?? "").isEmpty ? false : true

    sessionReporter.report(
      UserEvent.PerformAutofill(
        autofillMechanism: .iosTachyon,
        autofillOrigin: .automatic,
        fieldsFilled: .init(passkey: 1),
        formTypeList: [.login],
        isAutologin: false,
        isManual: false,
        matchType: .regular,
        space: isBusinessSpace ? .professional : .personal))
    applicationReporter.report(
      AnonymousEvent.PerformAutofill(
        autofillMechanism: .iosTachyon,
        autofillOrigin: .automatic,
        domain: passkeyRequest.credentialIdentity.serviceIdentifier.hashedDomainForLogs(),
        formTypeList: [.login],
        isAutologin: false,
        isManual: false,
        isNativeApp: true,
        matchType: .regular))

    sessionReporter.report(
      UserEvent.AutofillAccept(
        dataTypeList: [.passkey],
        itemPosition: nil))

    applicationReporter.report(
      AnonymousEvent.AuthenticateWithPasskey(
        authenticatorUserVerification: passkeyRequest.userVerificationPreference.log,
        domain: passkeyRequest.credentialIdentity.serviceIdentifier.hashedDomainForLogs(),
        hasCredentialsAllowed: true,
        isAuthenticatedWithDashlane: true,
        passkeyAuthenticationErrorType: nil,
        passkeyAuthenticationStatus: .success))
  }

  @available(iOS 17.0, macOS 14, *)
  func failedAssertion(for passkeyRequest: ASPasskeyCredentialRequest) {
    applicationReporter.report(
      AnonymousEvent.AuthenticateWithPasskey(
        authenticatorUserVerification: passkeyRequest.userVerificationPreference.log,
        domain: passkeyRequest.credentialIdentity.serviceIdentifier.hashedDomainForLogs(),
        hasCredentialsAllowed: true,
        isAuthenticatedWithDashlane: true,
        passkeyAuthenticationStatus: .failure))
  }

  @available(iOS 17.0, macOS 14, *)
  func registered(
    passkey: Passkey,
    passkeyRequest: ASPasskeyCredentialRequest
  ) {
    applicationReporter.report(
      AnonymousEvent.RegisterPasskey(
        algorithmsSupportedList: passkeyRequest.supportedAlgorithms.logs,
        authenticatorAttachment: .platform,
        authenticatorResidentKey: .required,
        authenticatorUserVerification: passkeyRequest.userVerificationPreference.log,
        domain: passkeyRequest.credentialIdentity.serviceIdentifier.hashedDomainForLogs(),
        passkeyRegistrationStatus: .success))
    sessionReporter.report(
      UserEvent.AutofillAccept(dataTypeList: [.passkey], webcardOptionSelected: .save))
    let isBusinessSpace = (passkey.spaceId ?? "").isEmpty ? false : true
    sessionReporter.report(
      UserEvent.UpdateVaultItem(
        action: .add,
        itemId: passkey.userTrackingLogID,
        itemType: .passkey,
        space: isBusinessSpace ? .professional : .personal))

  }

  @available(iOS 17.0, macOS 14, *)
  func failedRegistration(for passkeyRequest: ASPasskeyCredentialRequest) {
    applicationReporter.report(
      AnonymousEvent.RegisterPasskey(
        algorithmsSupportedList: passkeyRequest.supportedAlgorithms.logs,
        authenticatorAttachment: .platform,
        authenticatorResidentKey: .required,
        authenticatorUserVerification: passkeyRequest.userVerificationPreference.log,
        domain: passkeyRequest.credentialIdentity.serviceIdentifier.hashedDomainForLogs(),
        passkeyRegistrationStatus: .failure))
  }
}

extension ASCOSEAlgorithmIdentifier {
  fileprivate var log: Definition.AlgorithmsSupported? {
    switch self {
    case .ES256:
      return .es256
    default:
      return nil
    }
  }
}

extension [ASCOSEAlgorithmIdentifier] {
  fileprivate var logs: [Definition.AlgorithmsSupported] {
    return self.compactMap({ $0.log })
  }
}

extension ASAuthorizationPublicKeyCredentialUserVerificationPreference {
  var log: Definition.AuthenticatorUserVerification? {
    switch self {
    case .discouraged:
      return .discouraged
    case .preferred:
      return .preferred
    case .required:
      return .required
    default:
      return nil
    }
  }
}
