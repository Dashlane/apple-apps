import AuthenticationServices
import DashlaneAutofillKit
import UIComponents

class CredentialProviderViewController: ASCredentialProviderViewController,
  CredentialRootViewControllerContainer
{

  lazy var autofillRootCoordinatorTask: Task<AutofillRootCoordinator, Never> = Task {
    await AutofillRootCoordinator(context: extensionContext, container: self)
  }

  func autofillRootCoordinator() async -> AutofillRootCoordinator {
    await autofillRootCoordinatorTask.value
  }

  var rootViewController: UIViewController? {
    didSet {
      if let rootViewController {
        func enableRootViewControllerContraints() {
          rootViewController.view.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
            rootViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            rootViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
          ])
        }

        self.addChild(rootViewController)

        if let oldViewController = oldValue {
          oldViewController.willMove(toParent: nil)

          rootViewController.view.translatesAutoresizingMaskIntoConstraints = true
          rootViewController.view.frame = view.bounds

          self.transition(
            from: oldViewController,
            to: rootViewController,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
          ) { _ in
            oldViewController.removeFromParent()
            enableRootViewControllerContraints()
            rootViewController.didMove(toParent: self)
          }
        } else {
          view.addSubview(rootViewController.view)
          enableRootViewControllerContraints()
          rootViewController.didMove(toParent: self)
        }
      } else if let oldViewController = oldValue {
        oldViewController.willMove(toParent: nil)
        oldViewController.view.removeFromSuperview()
        oldViewController.removeFromParent()
      }
    }
  }

  override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    Task {
      rootViewController = nil
      await autofillRootCoordinator().prepareCredentialList(for: serviceIdentifiers)
    }
  }

  override func prepareInterfaceForExtensionConfiguration() {
    Task {
      rootViewController = nil
      await autofillRootCoordinator().prepareInterfaceForExtensionConfiguration()
    }
  }
}

extension CredentialProviderViewController {

  override func prepareCredentialList(
    for serviceIdentifiers: [ASCredentialServiceIdentifier],
    requestParameters: ASPasskeyCredentialRequestParameters
  ) {
    Task {
      rootViewController = nil
      await self.autofillRootCoordinator().prepareCredentialList(
        for: serviceIdentifiers, requestParameters: requestParameters)
    }
  }

  override func provideCredentialWithoutUserInteraction(for credentialRequest: ASCredentialRequest)
  {
    Task {
      rootViewController = nil
      await self.autofillRootCoordinator().provideCredentialWithoutUserInteraction(
        for: credentialRequest)
    }
  }

  override func prepareInterfaceToProvideCredential(for credentialRequest: ASCredentialRequest) {
    Task {
      rootViewController = nil
      await self.autofillRootCoordinator().prepareInterfaceToProvideCredential(
        for: credentialRequest)
    }
  }

  override func prepareInterface(forPasskeyRegistration registrationRequest: ASCredentialRequest) {
    Task {
      rootViewController = nil
      await self.autofillRootCoordinator().prepareInterface(
        forPasskeyRegistration: registrationRequest)
    }
  }
}

@available(iOS 18, visionOS 2.0, *)
extension CredentialProviderViewController {
  override func prepareOneTimeCodeCredentialList(
    for serviceIdentifiers: [ASCredentialServiceIdentifier]
  ) {
    Task {
      rootViewController = nil
      await self.autofillRootCoordinator().prepareOneTimeCodeCredentialList(for: serviceIdentifiers)
    }
  }

  #if !targetEnvironment(macCatalyst) && !os(visionOS)
    override func prepareInterfaceForUserChoosingTextToInsert() {
      Task {
        rootViewController = nil
        await self.autofillRootCoordinator().prepareInterfaceForUserChoosingTextToInsert()
      }
    }
  #endif

  override func performWithoutUserInteractionIfPossible(
    passkeyRegistration registrationRequest: ASPasskeyCredentialRequest
  ) {
    Task {
      rootViewController = nil
      await self.autofillRootCoordinator().performWithoutUserInteractionIfPossible(
        passkeyRegistration: registrationRequest)
    }
  }
}
