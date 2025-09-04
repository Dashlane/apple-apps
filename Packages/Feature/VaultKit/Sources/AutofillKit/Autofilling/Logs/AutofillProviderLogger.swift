import AuthenticationServices
import CorePersonalData
import CoreTypes
import CryptoKit
import Foundation
import UserTrackingFoundation

struct AutofillProviderLogger {
  let applicationReporter: ActivityReporterProtocol
  let sessionReporter: ActivityReporterProtocol
}

extension AutofillProviderLogger {
  func autofilled(
    _ credential: Credential,
    requiredUserSelection: Bool,
    matchType: Definition.MatchType,
    isOTP: Bool = false
  ) {
    let isBusinessSpace = (credential.spaceId ?? "").isEmpty ? false : true
    let event = UserEvent.PerformAutofill(
      autofillMechanism: .iosTachyon,
      autofillOrigin: requiredUserSelection ? .contextMenu : .automatic,
      fieldsFilled: isOTP ? .init(otp: 1) : .init(credential: 1),
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

}

extension AutofillProviderLogger {

  func autofilledFromContextMenu(_ vaultItem: VaultItem) {
    let isBusinessSpace = (vaultItem.spaceId ?? "").isEmpty ? false : true
    let event = UserEvent.PerformAutofill(
      autofillMechanism: .iosTachyon,
      autofillOrigin: .contextMenu,
      fieldsFilled: vaultItem.filledField,
      formTypeList: [.login],
      isAutologin: false,
      isManual: true,
      matchType: .explorePasswords,
      space: isBusinessSpace ? .professional : .personal)
    sessionReporter.report(event)

    applicationReporter.report(
      AnonymousEvent.PerformAutofill(
        autofillMechanism: .iosTachyon,
        autofillOrigin: .contextMenu,
        domain: vaultItem.hashedDomainForLogs(),
        formTypeList: [.login],
        isAutologin: false,
        isManual: true,
        isNativeApp: true,
        matchType: .explorePasswords))
  }
}

extension AutofillProviderLogger {
  func asserted(_ passkey: Passkey, for passkeyRequest: PasskeyAssertionRequest) {
    let passkeyType = Definition.PasskeyType(algorithm: passkey.keyAlgorithm)

    applicationReporter.report(
      AnonymousEvent.AuthenticateWithPasskey(
        authenticatorUserVerification: .init(passkeyRequest.userVerificationPreference),
        domain: passkeyRequest.serviceIdentifier.hashedDomainForLogs(),
        hasCredentialsAllowed: true,
        isAuthenticatedWithDashlane: true,
        passkeyAuthenticationErrorType: nil,
        passkeyAuthenticationStatus: .success,
        passkeyType: passkeyType)
    )

    sessionReporter.report(
      UserEvent.AuthenticateWithPasskey(
        passkeyAuthenticationStatus: .success, passkeyType: passkeyType)
    )
  }

  func failedAssertion(of passkey: Passkey? = nil, for passkeyRequest: PasskeyAssertionRequest) {
    let passkeyType = passkey.map {
      Definition.PasskeyType(algorithm: $0.keyAlgorithm)
    }

    applicationReporter.report(
      AnonymousEvent.AuthenticateWithPasskey(
        authenticatorUserVerification: .init(passkeyRequest.userVerificationPreference),
        domain: passkeyRequest.serviceIdentifier.hashedDomainForLogs(),
        hasCredentialsAllowed: true,
        isAuthenticatedWithDashlane: true,
        passkeyAuthenticationStatus: .failure,
        passkeyType: passkeyType)
    )

    sessionReporter.report(
      UserEvent.AuthenticateWithPasskey(
        passkeyAuthenticationStatus: .failure, passkeyType: passkeyType)
    )
  }

  func registered(_ passkey: Passkey, for passkeyRequest: ASPasskeyCredentialRequest) {
    let passkeyType = Definition.PasskeyType(algorithm: passkey.keyAlgorithm)

    applicationReporter.report(
      AnonymousEvent.RegisterPasskey(
        algorithmsSupportedList: .init(passkeyRequest.supportedAlgorithms),
        authenticatorAttachment: .platform,
        authenticatorResidentKey: .required,
        authenticatorUserVerification: .init(passkeyRequest.userVerificationPreference),
        domain: passkeyRequest.credentialIdentity.serviceIdentifier.hashedDomainForLogs(),
        passkeyRegistrationStatus: .success,
        passkeyType: passkeyType)
    )

    sessionReporter.report(
      UserEvent.RegisterPasskey(passkeyRegistrationStatus: .success, passkeyType: passkeyType)
    )
  }

  func failedRegistration(
    for passkeyRequest: ASPasskeyCredentialRequest, passkeyType: Definition.PasskeyType
  ) {
    applicationReporter.report(
      AnonymousEvent.RegisterPasskey(
        algorithmsSupportedList: .init(passkeyRequest.supportedAlgorithms),
        authenticatorAttachment: .platform,
        authenticatorResidentKey: .required,
        authenticatorUserVerification: .init(passkeyRequest.userVerificationPreference),
        domain: passkeyRequest.credentialIdentity.serviceIdentifier.hashedDomainForLogs(),
        passkeyRegistrationStatus: .failure)
    )
    sessionReporter.report(
      UserEvent.RegisterPasskey(passkeyRegistrationStatus: .failure, passkeyType: passkeyType)
    )
  }
}

extension Definition.PasskeyType {
  fileprivate init(algorithm: Passkey.KeyAlgorithm) {
    switch algorithm {
    case .cloud:
      self = .cloud
    case .local:
      self = .legacy
    }
  }
}

extension Definition.AlgorithmsSupported {
  fileprivate init?(_ algorithm: ASCOSEAlgorithmIdentifier) {
    switch algorithm {
    case .ES256:
      self = .es256
    default:
      return nil
    }
  }
}

extension [Definition.AlgorithmsSupported] {
  fileprivate init(_ supportedAlgorithms: [ASCOSEAlgorithmIdentifier]) {
    self = supportedAlgorithms.compactMap(Definition.AlgorithmsSupported.init)
  }
}

extension Definition.AuthenticatorUserVerification {
  fileprivate init?(
    _ userVerificationPreference: ASAuthorizationPublicKeyCredentialUserVerificationPreference
  ) {
    switch userVerificationPreference {
    case .discouraged:
      self = .discouraged
    case .preferred:
      self = .preferred
    case .required:
      self = .required
    default:
      return nil
    }
  }

}

extension VaultItem {
  fileprivate var filledField: Definition.FieldsFilled {
    switch self.enumerated {
    case .credential:
      return .init(credential: 1)
    case .secureNote:
      return .init(secureNote: 1)
    case .secret:
      return .init(secureNote: 1)
    case .bankAccount:
      return .init(bankStatement: 1)
    case .creditCard:
      return .init(creditCard: 1)
    case .identity:
      return .init(identity: 1)
    case .email:
      return .init(email: 1)
    case .phone:
      return .init(phone: 1)
    case .address:
      return .init(address: 1)
    case .company:
      return .init(company: 1)
    case .personalWebsite:
      return .init(website: 1)
    case .passport:
      return .init(passport: 1)
    case .idCard:
      return .init(idCard: 1)
    case .fiscalInformation:
      return .init(fiscalStatement: 1)
    case .socialSecurityInformation:
      return .init(socialSecurity: 1)
    case .drivingLicence:
      return .init(driverLicense: 1)
    case .passkey:
      return .init(passkey: 1)
    case .wifi:
      return .init(wifi: 1)
    }
  }
}
