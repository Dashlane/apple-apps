import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    private static var extensionRoot: SafariExtensionRoot!
    
    override init() {
        
        if Self.extensionRoot == nil {
            Self.extensionRoot = SafariExtensionRoot(enclosingViewController: SafariExtensionViewController.shared)
            Self.extensionRoot.start()
        }
        
        super.init()
    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        Self.extensionRoot.messageReceived(withName: messageName, from: page, userInfo: userInfo)
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        Self.extensionRoot.validateToolbarItem(in: window, validationHandler: validationHandler)
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        SafariExtensionViewController.shared.contentViewController = Self.extensionRoot.mainViewController
        Self.extensionRoot.resume()
        return SafariExtensionViewController.shared
    }

    override func popoverDidClose(in window: SFSafariWindow) {
        Self.extensionRoot.popoverDidClose()
    }

}
