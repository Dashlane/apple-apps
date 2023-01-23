import Foundation
import SafariServices
import JavaScriptCore
import DashTypes
import DashlaneCrypto

@objc private protocol BrowserExport: JSExport {
    func getActiveTab( _ callback: JSValue ) 
    func setToolbarItemImage( _ name: String )
    func setToolbarItemEnabled( _ enabled: Bool )
    func getRandomValues(_ size: Int ) -> [UInt8]
    func openNewTabWithUrl( _ url: String )
    func getLanguages() -> [String]
    func doesExtensionSupportCommunicationWithLocalRessource(_ safariVersionNumber: String) -> Bool
    func tabsOnUpdatedAddListener(_ callback: JSValue)
    func tabsSendMessage(_ tabId: Int, _ message: String, _ options: [String: Any])
    func getURL(_ ofResource: String) -> String?
    func runtimeOnMessageAddListener(_ callback: JSValue)
    func tabsDetectLanguage(_ tabId: Int) -> String
    func fetchLocalFile(_ rawURL: String) -> String
    func fetchRawLocalFile(_ rawURL: String) -> [UInt8]
}

enum ListenerType {
    case onUpdated
    case onMessage
}

protocol BrowserInformationProvider {
    func getTabId(page: SFSafariPage) -> Int?
    func getTab(fromID: Int) -> DashlaneSafariPage?
    func addListener(for type: ListenerType, value: JSValue)
}

public final class Browser: NSObject, BrowserExport {
    
    private let logger: Logger?
    private let informationProvider: BrowserInformationProvider
    
    init(informationProvider: BrowserInformationProvider, logger: Logger?) {
        self.informationProvider = informationProvider
        self.logger = logger
        super.init()
    }
    
    func getActiveTab( _ callback: JSValue ) {
        guard callback.isObject else {
            logger?.error("wrong calllback")
            return
        }
        self._getActiveTab { tabId in
            let _tabId: Int = tabId ?? 1
            callback.call(withArguments: [_tabId as Any])
        }
    }
    
    private func _getActiveTab(completion: @escaping (Int?) -> Void )  {
                SFSafariApplication.getActiveWindow { window in
            guard let window = window else { completion(nil); return }
            window.getActiveTab { tab in
                guard let tab = tab else { completion(nil); return }
                tab.getActivePage { page in
                    guard let page = page else { completion(nil); return }
                    let tabId = self.informationProvider.getTabId(page: page)
                    completion(tabId)
                }
            }
        }
    }
    
        func setToolbarItemImage( _ name: String ) {
    }
    
        func setToolbarItemEnabled( _ enabled: Bool ) {
    }
    
    func getRandomValues(_ size: Int ) -> [UInt8] {
        Array(Random.randomData(ofSize: size))
    }
  
    func openNewTabWithUrl( _ url: String )  {
        guard let url = URL(string: url) else { return }
        SFSafariApplication.getActiveWindow { window in
            window?.openTab(with: url, makeActiveIfPossible: true) { tab in
                            }
        }
    }

    func getLanguages() -> [String] {
        return NSLocale.preferredLanguages
    }
    
    func doesExtensionSupportCommunicationWithLocalRessource(_ safariVersionNumber: String) -> Bool {
                                       return true
    }
    
        
    func getURL(_ ofResource: String) -> String? {
        return Bundle(for: Browser.self).resourceURL?.appendingPathComponent(ofResource).absoluteString
    }
    
    func runtimeOnMessageAddListener(_ callback: JSValue) {
        guard callback.isObject else {
            assertionFailure("Not an object")
            return
        }
        informationProvider.addListener(for: .onMessage, value: callback)
    }
    
        
    func tabsSendMessage(_ tabId: Int, _ message: String, _ options: [String: Any]) {
        guard let tab = informationProvider.getTab(fromID: tabId) else {
            logger?.error("Could not find tab with id \(tabId)")
            return
        }
        tab.dashlaneMessageToWebPage(message, options, logger)
    }
    
    func tabsOnUpdatedAddListener(_ callback: JSValue) {
        guard callback.isObject else {
            assertionFailure("Not an object")
            return
        }
        informationProvider.addListener(for: .onUpdated, value: callback)
    }
    
        
    func tabsDetectLanguage(_ tabId: Int) -> String {
                    return "en"
    }
    
    func fetchLocalFile(_ rawURL: String) -> String {
        let url = URL(string: rawURL)!
        guard let data = try? Data(contentsOf: url) else {
            assertionFailure("File not read")
            return ""
        }
        return String(decoding: data, as: UTF8.self)
    }

    func fetchRawLocalFile(_ rawURL: String) -> [UInt8] {
        let url = URL(string: rawURL)!
        guard let data = try? Data(contentsOf: url) else {
            assertionFailure("File not read")
            return []
        }
        return Array<UInt8>(data)
    }

}
