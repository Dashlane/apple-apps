import Foundation
import SafariServices
import DashTypes
import CorePasswords
import DomainParser
import CorePersonalData

final class AutofillService: NSObject {
    
    private let injectedService: InjectedService
    private let backgroundService: BackgroundService
    private let pluginService: PluginService

    var isConnected: Bool = false {
        didSet {
            ExtensionIconUpdater.setIconEnabled(isConnected)
        }
    }
    private let messageDispatcher: AutofillMessageDispatcher

        let analysisLocalStorage: AutofillStorage

    init(services: AutofillAppServicesContainer) {
        let dispatcher = AutofillMessageDispatcher(logger: services.logger)
        self.messageDispatcher = dispatcher
        self.pluginService = PluginService(appServices: services,
                                           messageDispatcher: messageDispatcher)
        self.injectedService = InjectedService(logger: services.logger,
                                               messageDispatcher: messageDispatcher)
        let browser = Browser(informationProvider: injectedService, logger: services.logger)
        self.backgroundService = BackgroundService(browser: browser, messageDispatcher: messageDispatcher, logger: services.logger)
        self.analysisLocalStorage = AutofillStorage(postSettingsUpdate: { dispatcher.post($0.communication()) })
        super.init()
    }
    
    public func connect(sessionServices: SessionServicesContainer) {
        isConnected = true
        pluginService.connect(sessionServicesContainer: sessionServices)
    }
    
    public func disconnect() {
        isConnected = false
        pluginService.disconnect()
    }
}

extension AutofillService: SFSafariExtensionHandling {
    public func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        injectedService.messageReceived(withName: messageName, from: page, userInfo: userInfo)
    }
    
    public func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        ExtensionIconUpdater.setIconEnabled(isConnected)
        validationHandler(true, "")
    }
}
