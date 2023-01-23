import Foundation
import SwiftUI
import SafariServices
import Combine

public final class SafariExtensionRoot {
 
    let appServices: SafariExtensionAppServices

    public private(set) lazy var mainViewController: NSViewController = {
        NSHostingController(rootView: RootView(viewModel: userSessionViewModel))
    }()
    
    private lazy var userSessionViewModel: UserSessionViewModel = {
        UserSessionViewModel(appServices: appServices)
    }()
    
    public init(enclosingViewController: SFSafariExtensionViewController) {
        appServices = SafariExtensionAppServices(enclosingViewController: enclosingViewController)
    }
    
    public func start() {
        userSessionViewModel.start()
    }
    
    public func resume() {
        appServices.popoverOpeningService.popoverDidOpen()
        userSessionViewModel.resume()
    }

    public func popoverDidClose() {
        appServices.popoverOpeningService.popoverDidClose()
    }
    
    public func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        appServices.autofillService.messageReceived(withName: messageName, from: page, userInfo: userInfo)
    }
    
    public func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        appServices.autofillService.validateToolbarItem(in: window, validationHandler: validationHandler)
    }
}
