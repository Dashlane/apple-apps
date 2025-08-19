import AuthenticationServices
import AutofillKit
import CorePersonalData
import Foundation
import LogFoundation
import Logger
import LoginKit
import SwiftUI
import UIKit
import WebAuthn

@Loggable
enum CredentialProviderError: Error {
  case didNotFindPasskeyInDatabase
  case didNotReceivePasskeyRequest
  case passkeyAlreadyExist
  case unknownCredentialRequest
}

extension AutofillRootCoordinator {
  public func prepareInterfaceForExtensionConfiguration() {
    let configurationViewController: UIViewController
    #if !targetEnvironment(macCatalyst)
      configurationViewController = UIHostingController(
        rootView: CredentialProviderConfigurationView(completion: { [weak context] in
          context?.completeExtensionConfigurationRequest()
        }))
    #else
      configurationViewController = UIHostingController(
        rootView: CredentialProviderConfigurationCatalystView(completion: { [weak context] in
          context?.completeExtensionConfigurationRequest()
        }))
    #endif
    container.rootViewController = configurationViewController
  }
}

extension AutofillRootCoordinator {
  public func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    logger.info("Present list for \(serviceIdentifiers.map(\.identifier))")

    Task {
      let request = CredentialsListRequest(
        servicesIdentifiers: serviceIdentifiers, type: .passwords)
      await prepareCredentialList(for: request)
    }
  }

  public func prepareCredentialList(
    for serviceIdentifiers: [ASCredentialServiceIdentifier],
    requestParameters: ASPasskeyCredentialRequestParameters
  ) {
    Task {

      if shouldResetInMemorySession(for: requestParameters.userVerificationPreference) {
        logger.info(
          "Session reset based on userVerificationPreference \(requestParameters.userVerificationPreference)"
        )
        self.cleanPersistedServices()
      }

      let request = CredentialsListRequest(
        servicesIdentifiers: serviceIdentifiers,
        type: .passkeysAndPasswords(request: requestParameters))
      await prepareCredentialList(for: request)
    }
  }

  @available(iOS 18, *)
  public func prepareOneTimeCodeCredentialList(
    for serviceIdentifiers: [ASCredentialServiceIdentifier]
  ) {
    Task {
      let request = CredentialsListRequest(servicesIdentifiers: serviceIdentifiers, type: .otps)
      await prepareCredentialList(for: request)
    }
  }

  private func prepareCredentialList(for request: CredentialsListRequest) async {
    logger.info("Present list for \(request)")

    do {
      let (sessionServices, hasUserBeenVerified) =
        try await retrieveSessionServicesFromMemoryOrPresentLogin()

      let autofillProvider = sessionServices.makeAutofillProvider(
        context: context, hasUserBeenVerified: hasUserBeenVerified)
      let model = sessionServices.makeCredentialProviderFlowModel(
        autofillProvider: autofillProvider, request: request)

      let view = CredentialProviderFlow(model: model)
      self.container.setRootView(view)
    } catch {
      logger.error("Present list failed", error: error)

      await self.displayErrorStateOrCancelRequest(error: error)
    }
  }

  @available(iOS 18, *)
  @available(macCatalyst, unavailable)
  @available(visionOS, unavailable)
  public func prepareInterfaceForUserChoosingTextToInsert() {
    logger.info("Present list for choosing text to Insert")

    Task {
      await prepareContextMenuVaultItemsList()
    }
  }

  @available(iOS 18, *)
  @available(macCatalyst, unavailable)
  @available(visionOS, unavailable)
  private func prepareContextMenuVaultItemsList() async {
    logger.info("Present list for context menu autofill")

    do {
      let (sessionServices, hasUserBeenVerified) =
        try await retrieveSessionServicesFromMemoryOrPresentLogin()
      let autofillProvider = sessionServices.makeAutofillProvider(
        context: context,
        hasUserBeenVerified: hasUserBeenVerified)
      let model = sessionServices.makeContextMenuVaultItemsProviderFlowModel(
        autofillProvider: autofillProvider)
      let view = ContextMenuVaultItemsProviderFlow(model: model)
      self.container.setRootView(view)
    } catch {
      logger.error("Present list failed", error: error)

      await self.displayErrorStateOrCancelRequest(error: error)
    }
  }
}

extension AutofillRootCoordinator {
  public func provideCredentialWithoutUserInteraction(for credentialRequest: ASCredentialRequest) {
    logger.info("Autofill without UI \(credentialRequest.credentialIdentity.serviceIdentifier)")

    Task {
      do {
        let shouldCheckLock = credentialRequest.type.requireUnlockedExtension
        guard
          let sessionServices = retrieveSessionServicesFromMemory(shouldCheckLock: shouldCheckLock)
        else {
          cleanPersistedServices()
          logger.info("No session, open UI")

          throw NSError(.userInteractionRequired)
        }

        let autofillProvider = sessionServices.makeAutofillProvider(
          context: context,
          hasUserBeenVerified: false)

        switch credentialRequest.type {
        case .password:
          guard let request = credentialRequest as? ASPasswordCredentialRequest else { fallthrough }

          try await authenticate(request, autofillProvider: autofillProvider)

          logger.info("Credential provided")

        case .passkeyAssertion:
          guard let request = credentialRequest as? ASPasskeyCredentialRequest else { fallthrough }
          if shouldResetInMemorySession(for: request.userVerificationPreference) {
            context.cancelRequest(withError: NSError(.userInteractionRequired))
            return
          }

          try await autofillProvider.autofillPasskey(for: request)

          logger.info("Passkey assertion provided")

        case .oneTimeCode:
          if #available(iOS 18.0, visionOS 2.0, *) {
            guard let request = credentialRequest as? ASOneTimeCodeCredentialRequest else {
              fallthrough
            }
            guard
              let credentialIdentity = request.credentialIdentity
                as? ASOneTimeCodeCredentialIdentity
            else {
              context.cancelRequest(withError: CredentialProviderError.unknownCredentialRequest)
              return
            }

            try await autofillProvider.autofillOTPCredential(for: credentialIdentity)

            logger.info("OTP provided")
          } else {
            fallthrough
          }

        case .passkeyRegistration:
          fallthrough

        @unknown default:
          logger.error("Unknown credential request \(credentialRequest.type)")

          context.cancelRequest(withError: CredentialProviderError.unknownCredentialRequest)
        }
      } catch {
        logger.warning("Autofill without UI fails, present UI", error: error)

        context.cancelRequest(withError: NSError(.userInteractionRequired))
      }
    }
  }

  private func authenticate(
    _ passwordRequest: ASPasswordCredentialRequest, autofillProvider: AutofillProvider
  ) async throws {
    guard
      let credentialIdentity = passwordRequest.credentialIdentity as? ASPasswordCredentialIdentity
    else {
      context.cancelRequest(withError: CredentialProviderError.unknownCredentialRequest)
      return
    }
    try await autofillProvider.autofillPassword(for: credentialIdentity)
  }

  public func prepareInterfaceToProvideCredential(for credentialRequest: ASCredentialRequest) {
    Task {
      logger.info(
        "Present UI to autofill \(credentialRequest.credentialIdentity.serviceIdentifier)")

      do {
        switch credentialRequest.type {
        case .password:
          let (sessionServices, hasUserBeenVerified) =
            try await retrieveSessionServicesFromMemoryOrPresentLogin()
          let autofillProvider = sessionServices.makeAutofillProvider(
            context: context,
            hasUserBeenVerified: hasUserBeenVerified)
          guard let request = credentialRequest as? ASPasswordCredentialRequest else { return }
          try await authenticate(request, autofillProvider: autofillProvider)

          logger.info("Credential provided")

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

          logger.info("Passkey assertion provided")

        case .oneTimeCode:
          if #available(iOS 18.0, visionOS 2.0, *) {
            guard let request = credentialRequest as? ASOneTimeCodeCredentialRequest else { return }
            guard
              let credentialIdentity = request.credentialIdentity
                as? ASOneTimeCodeCredentialIdentity
            else {
              context.cancelRequest(withError: CredentialProviderError.unknownCredentialRequest)
              return
            }

            let (sessionServices, hasBeenVerified) =
              try await retrieveSessionServicesFromMemoryOrPresentLogin()
            let autofillProvider = sessionServices.makeAutofillProvider(
              context: context,
              hasUserBeenVerified: hasBeenVerified)
            try await autofillProvider.autofillOTPCredential(for: credentialIdentity)

            logger.info("OTP provided")
          }

        case .passkeyRegistration:
          fallthrough

        @unknown default:
          logger.error("Unknown credential request \(credentialRequest.type)")
          context.cancelRequest(withError: CredentialProviderError.unknownCredentialRequest)
        }
      } catch {
        await self.displayErrorStateOrCancelRequest(error: error)
      }
    }
  }
}

extension AutofillRootCoordinator {
  @available(iOS 17.0, *)
  public func prepareInterface(forPasskeyRegistration registrationRequest: ASCredentialRequest) {
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
        try await autofillProvider.registerPasskey(
          for: passkeyRequest,
          syncService: sessionServices.syncService)
      } catch {
        await self.displayErrorStateOrCancelRequest(error: error)
      }
    }
  }

  @available(iOS 18.0, *)
  public func performWithoutUserInteractionIfPossible(
    passkeyRegistration passkeyRequest: ASPasskeyCredentialRequest
  ) {
    logger.info(
      "Perform passkey registration without UI for \(passkeyRequest.credentialIdentity.serviceIdentifier)"
    )

    Task {
      let shouldCheckLock = passkeyRequest.type.requireUnlockedExtension
      guard
        let sessionServices = retrieveSessionServicesFromMemory(shouldCheckLock: shouldCheckLock)
      else {
        cleanPersistedServices()
        logger.error("No session available for passkey registration in background")

        context.cancelRequest(withError: NSError(.userInteractionRequired))
        return
      }

      let rpId = passkeyRequest.credentialIdentity.serviceIdentifier.identifier
      let exist = try sessionServices.database.fetchAll(Passkey.self)
        .contains { $0.relyingPartyId.rawValue == rpId }

      guard !exist else {
        logger.error("A passkey already exists")

        context.cancelRequest(withError: CredentialProviderError.passkeyAlreadyExist)
        return
      }

      let autofillProvider = sessionServices.makeAutofillProvider(
        context: context, hasUserBeenVerified: false)
      try await autofillProvider.registerPasskey(
        for: passkeyRequest,
        syncService: sessionServices.syncService)

      logger.info("Passkey saved in vault")
    }
  }
}

extension SessionServicesContainer {
  @MainActor
  func makeAutofillProvider(
    context: ASCredentialProviderExtensionContext,
    hasUserBeenVerified: Bool
  ) -> AutofillProvider {
    let otpNotificaitonSender = self.otpNotificaitonSender
    return AutofillProvider(
      hasUserBeenVerified: hasUserBeenVerified,
      database: database,
      applicationReporter: appServices.activityReporter,
      sessionReporter: activityReporter,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      autofillService: autofillService,
      teamAuditLogsService: teamAuditLogsService,
      cloudPasskeyAPIClient: encryptedAPIClient.passkeys,
      otpNotificationSender: { otpNotificaitonSender.send(for: $0) },
      logger: appServices.rootLogger[.autofill],
      context: context)
  }
}

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

@available(iOSApplicationExtension 17.0, *)
extension ASCredentialRequestType {
  var requireUnlockedExtension: Bool {
    switch self {
    case .password, .passkeyAssertion:
      return true
    case .passkeyRegistration, .oneTimeCode:
      return false
    @unknown default:
      return true
    }
  }
}
