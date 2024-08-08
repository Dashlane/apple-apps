import AuthenticationServices
import AutofillKit
import CorePersonalData
import Foundation
import LoginKit
import WebAuthn

enum CredentialProviderError: Error {
  case didNotFindPasskeyInDatabase
  case didNotReceivePasskeyRequest
  case unknownCredentialRequest
}

@available(iOS 17, *)
extension AutofillRootCoordinator: CredentialProvider {
  func prepareCredentialList(
    for serviceIdentifiers: [ASCredentialServiceIdentifier],
    requestParameters: ASPasskeyCredentialRequestParameters
  ) {
    logger.info(
      "Present list for \(serviceIdentifiers.map(\.identifier)), \(requestParameters.relyingPartyIdentifier)"
    )
    Task {
      if shouldResetInMemorySession(for: requestParameters.userVerificationPreference) {
        self.cleanPersistedServices()
      }
      do {
        let request = CredentialsListRequest.servicesAndPasskey(
          servicesIdentifiers: serviceIdentifiers,
          passkeyAssertionRequest: requestParameters.makePasskeyAssertionRequest())
        let connectedCoordinator = try await retrieveConnectedCoordinator(for: request)

        connectedCoordinator.logLogin()

        connectedCoordinator.prepareCredentialList(context: context)
      } catch {
        logger.error("Present list failed", error: error)

        await self.displayErrorStateOrCancelRequest(error: error)
      }
    }
  }

  func provideCredentialWithoutUserInteraction(for credentialRequest: ASCredentialRequest) {
    logger.info("Autofill without UI \(credentialRequest.credentialIdentity.serviceIdentifier)")

    Task {
      do {
        guard let sessionServices = retrieveSessionServicesFromMemory() else {
          cleanPersistedServices()
          throw ASExtensionError.userInteractionRequired.nsError
        }
        switch credentialRequest.type {
        case .password:
          guard let request = credentialRequest as? ASPasswordCredentialRequest else { fallthrough }
          let autofillProvider = sessionServices.makeAutofillProvider(
            context: context,
            hasUserBeenVerified: false)
          try authenticate(request, autofillProvider: autofillProvider)
        case .passkeyAssertion:
          guard let request = credentialRequest as? ASPasskeyCredentialRequest else { fallthrough }
          if shouldResetInMemorySession(for: request.userVerificationPreference) {
            context.cancelRequest(withError: ASExtensionError.userInteractionRequired.nsError)
            return
          }
          let autofillProvider = sessionServices.makeAutofillProvider(
            context: context,
            hasUserBeenVerified: false)
          try await autofillProvider.autofillPasskey(for: request)

        @unknown default:
          context.cancelRequest(withError: CredentialProviderError.unknownCredentialRequest)
        }
      } catch {
        logger.warning("Autofill without UI fails, present UI", error: error)

        context.cancelRequest(withError: ASExtensionError.userInteractionRequired.nsError)
      }
    }
  }

  private func authenticate(
    _ passwordRequest: ASPasswordCredentialRequest, autofillProvider: AutofillProvider
  ) throws {
    guard
      let credentialIdentity = passwordRequest.credentialIdentity as? ASPasswordCredentialIdentity
    else {
      context.cancelRequest(withError: CredentialProviderError.unknownCredentialRequest)
      return
    }
    try autofillProvider.autofillPasswordCredential(for: credentialIdentity)
  }

  func prepareInterfaceToProvideCredential(for credentialRequest: ASCredentialRequest) {
    logger.info("Present UI to autofill \(credentialRequest.credentialIdentity.serviceIdentifier)")

    Task {
      do {
        switch credentialRequest.type {
        case .password:
          let (sessionServices, hasUserBeenVerified) =
            try await retrieveSessionServicesFromMemoryOrPresentLogin()
          let autofillProvider = sessionServices.makeAutofillProvider(
            context: context,
            hasUserBeenVerified: hasUserBeenVerified)
          guard let request = credentialRequest as? ASPasswordCredentialRequest else { return }
          try authenticate(request, autofillProvider: autofillProvider)
        case .passkeyAssertion:
          guard let request = credentialRequest as? ASPasskeyCredentialRequest else { return }
          if shouldResetInMemorySession(for: request.userVerificationPreference) {
            self.cleanPersistedServices()
          }
          let (sessionServices, hasBeenVerified) =
            try await retrieveSessionServicesFromMemoryOrPresentLogin()
          let autofillProvider = sessionServices.makeAutofillProvider(
            context: context,
            hasUserBeenVerified: hasBeenVerified)
          try await autofillProvider.autofillPasskey(for: request)
        @unknown default:
          context.cancelRequest(withError: CredentialProviderError.unknownCredentialRequest)
        }
      } catch {
        await self.displayErrorStateOrCancelRequest(error: error)
      }
    }
  }

  func prepareInterface(forPasskeyRegistration registrationRequest: ASCredentialRequest) {
    logger.info(
      "Register a passkey with UI for \(registrationRequest.credentialIdentity.serviceIdentifier)")

    Task {
      do {
        guard let passkeyRequest = registrationRequest as? ASPasskeyCredentialRequest else {
          context.cancelRequest(withError: CredentialProviderError.didNotReceivePasskeyRequest)
          return
        }
        if shouldResetInMemorySession(for: passkeyRequest.userVerificationPreference) {
          self.cleanPersistedServices()
        }
        let (sessionServices, hasUserBeenVerified) =
          try await retrieveSessionServicesFromMemoryOrPresentLogin()
        let autofillProvider = sessionServices.makeAutofillProvider(
          context: context,
          hasUserBeenVerified: hasUserBeenVerified)
        try await autofillProvider.savePasskey(
          for: passkeyRequest,
          syncService: sessionServices.syncService)
      } catch {
        await self.displayErrorStateOrCancelRequest(error: error)
      }
    }
  }
}

extension SessionServicesContainer {
  @MainActor
  func makeAutofillProvider(
    context: ASCredentialProviderExtensionContext,
    hasUserBeenVerified: Bool
  ) -> AutofillProvider {
    let notificationSender = OTPNotificationSender(
      userSettings: userSettings,
      localNotificationService: LocalNotificationService())
    return AutofillProvider(
      hasUserBeenVerified: hasUserBeenVerified,
      database: database,
      applicationReporter: appServices.activityReporter,
      sessionReporter: activityReporter,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      autofillService: autofillService,
      otpNotificationSender: { notificationSender.send(for: $0) },
      context: context)
  }
}

@available(iOS 17, *)
extension AutofillRootCoordinator {

  fileprivate func shouldResetInMemorySession(
    for userVerificationPreference: ASAuthorizationPublicKeyCredentialUserVerificationPreference
  ) -> Bool {
    guard userVerificationPreference != .required else {
      return true
    }

    if let sessionServices = retrieveSessionServicesFromMemory(),
      userVerificationPreference == .preferred,
      sessionServices.makeSecureLockProvider().isUsingBiometryOrPin()
    {
      return true
    }
    return false
  }
}

extension SessionServicesContainer {
  fileprivate func makeSecureLockProvider() -> SecureLockProviderProtocol {
    SecureLockProvider(
      login: self.session.login,
      settings: self.settings,
      keychainService: self.appServices.keychainService)
  }
}

extension SecureLockProviderProtocol {
  fileprivate func isUsingBiometryOrPin() -> Bool {
    let mode = secureLockMode(checkIsBiometricSetIntact: false)
    return switch mode {
    case .biometry, .biometryAndPincode, .pincode:
      true
    case .masterKey, .rememberMasterPassword:
      false
    }
  }
}
