import AuthenticationServices
import AutofillKit
import CoreSettings
import Foundation
import SwiftUI

extension AutofillRootCoordinator: LegacyCredentialProvider {
  func prepareInterfaceForExtensionConfiguration() {
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
    rootNavigationController.setViewControllers([configurationViewController], animated: true)
  }

  func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    logger.info("Present list for \(serviceIdentifiers.map(\.identifier))")

    Task {
      do {
        let connectedCoordinator = try await retrieveConnectedCoordinator(
          for: .legacy(serviceIdentifiers))

        connectedCoordinator.logLogin()
        connectedCoordinator.prepareCredentialList(context: context)
      } catch {
        await self.displayErrorStateOrCancelRequest(error: error)
      }
    }
  }

  func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity)
  {
    logger.info("Legacy - Autofill without UI \(credentialIdentity.serviceIdentifier)")

    Task {
      do {
        guard let sessionServices = retrieveSessionServicesFromMemory() else {
          cleanPersistedServices()
          throw ASExtensionError.userInteractionRequired.nsError
        }
        let autofillProvider = sessionServices.makeAutofillProvider(
          context: context,
          hasUserBeenVerified: false)
        try autofillProvider.autofillPasswordCredential(for: credentialIdentity)
      } catch {
        self.context.cancelRequest(withError: ASExtensionError.userInteractionRequired.nsError)
      }
    }
  }

  func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
    logger.info("Legacy - Present UI to autofill \(credentialIdentity.serviceIdentifier)")

    Task {
      do {
        let (sessionServices, hasUserBeenVerified) =
          try await retrieveSessionServicesFromMemoryOrPresentLogin()
        let autofillProvider = sessionServices.makeAutofillProvider(
          context: context,
          hasUserBeenVerified: hasUserBeenVerified)
        try autofillProvider.autofillPasswordCredential(for: credentialIdentity)
      } catch AutofillProvider.Error.couldNotFindCredential {
        let connectedCoordinator = try await retrieveConnectedCoordinator(for: .legacy([]))
        connectedCoordinator.prepareCredentialList(context: context)
      } catch {
        await self.displayErrorStateOrCancelRequest(error: error)
      }
    }
  }
}
