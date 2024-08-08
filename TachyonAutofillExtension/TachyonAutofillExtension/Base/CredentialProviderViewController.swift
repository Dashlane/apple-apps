import AuthenticationServices
import UIComponents

class CredentialProviderViewController: ASCredentialProviderViewController {

  var rootNavigationController: DashlaneNavigationController!

  lazy var autofillRootCoordinator = AutofillRootCoordinator(
    context: extensionContext,
    rootViewController: rootNavigationController)

  override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    autofillRootCoordinator.prepareCredentialList(for: serviceIdentifiers)
  }

  override func provideCredentialWithoutUserInteraction(
    for credentialIdentity: ASPasswordCredentialIdentity
  ) {
    autofillRootCoordinator.provideCredentialWithoutUserInteraction(for: credentialIdentity)
  }

  override func prepareInterfaceToProvideCredential(
    for credentialIdentity: ASPasswordCredentialIdentity
  ) {
    autofillRootCoordinator.prepareInterfaceToProvideCredential(for: credentialIdentity)
  }

  override func prepareInterfaceForExtensionConfiguration() {
    autofillRootCoordinator.prepareInterfaceForExtensionConfiguration()
  }

  func embedRootNavigationController() {
    let navigationController = DashlaneNavigationController()
    addChild(navigationController)
    navigationController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(navigationController.view)

    navigationController.setNavigationBarHidden(true, animated: false)

    NSLayoutConstraint.activate([
      navigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      navigationController.view.trailingAnchor.constraint(
        equalTo: view.trailingAnchor, constant: 0),
      navigationController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
      navigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
    ])
    navigationController.didMove(toParent: self)
    self.rootNavigationController = navigationController
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    embedRootNavigationController()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? DashlaneNavigationController {
      self.rootNavigationController = navigationController
    }
  }
}

@available(iOS 17, *)
extension CredentialProviderViewController {

  override func prepareCredentialList(
    for serviceIdentifiers: [ASCredentialServiceIdentifier],
    requestParameters: ASPasskeyCredentialRequestParameters
  ) {
    self.autofillRootCoordinator.prepareCredentialList(
      for: serviceIdentifiers, requestParameters: requestParameters)
  }

  override func provideCredentialWithoutUserInteraction(for credentialRequest: ASCredentialRequest)
  {
    self.autofillRootCoordinator.provideCredentialWithoutUserInteraction(for: credentialRequest)
  }

  override func prepareInterfaceToProvideCredential(for credentialRequest: ASCredentialRequest) {
    self.autofillRootCoordinator.prepareInterfaceToProvideCredential(for: credentialRequest)
  }

  override func prepareInterface(forPasskeyRegistration registrationRequest: ASCredentialRequest) {
    self.autofillRootCoordinator.prepareInterface(forPasskeyRegistration: registrationRequest)
  }
}
