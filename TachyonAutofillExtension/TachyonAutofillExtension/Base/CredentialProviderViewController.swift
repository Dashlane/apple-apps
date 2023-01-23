import AuthenticationServices

class CredentialProviderViewController: ASCredentialProviderViewController {
    
    var rootNavigationController: DashlaneNavigationController!

    lazy var credentialProvider: CredentialProvider = {
        
        return AutofillRootCoordinator(context: extensionContext,
                                       rootViewController: rootNavigationController,
                                       sharedSessionServices: SessionServicesContainer.shared)
    }()

        override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        credentialProvider.prepareCredentialList(for: serviceIdentifiers)
    }
    
        override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        credentialProvider.provideCredentialWithoutUserInteraction(for: credentialIdentity)
    }


        override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        credentialProvider.prepareInterfaceToProvideCredential(for: credentialIdentity)
    }
    
        override func prepareInterfaceForExtensionConfiguration() {
        credentialProvider.prepareInterfaceForExtensionConfiguration()
    }
    
    func embedRootNavigationController() {
        let navigationController = DashlaneNavigationController()
        addChild(navigationController)
        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationController.view)

        navigationController.setNavigationBarHidden(true, animated: false)

        NSLayoutConstraint.activate([
            navigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            navigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:0),
            navigationController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            navigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
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
