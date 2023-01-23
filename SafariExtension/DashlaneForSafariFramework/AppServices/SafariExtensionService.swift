import Foundation
import SafariServices
import DashTypes

class SafariExtensionService: Mockable {
    
    private let enclosingViewController: SFSafariExtensionViewController
    
    init(enclosingViewController: SFSafariExtensionViewController) {
        self.enclosingViewController = enclosingViewController
    }
    
    public func dismissPopover() {
        enclosingViewController.dismissPopover()
    }
}

struct SafariExtensionServiceMock: SafariExtensionServiceProtocol {
    func dismissPopover() {
        print("Dismiss")
    }
}
