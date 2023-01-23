import Foundation
import DashTypes
import SafariServices
import JavaScriptCore

private let machineLearningMessageKey = "tiresias"

public final class InjectedService: NSObject, BrowserInformationProvider {
    
    private let logger: Logger?
    private let queue = DispatchQueue(label: "com.dashlane.InjectedService", qos: .userInitiated)
    private let tabsQueue = DispatchQueue(label: "com.dashlane.InjectedService.tabsQueue", qos: .userInitiated)
    
    private var pagesByTabId = [Int: DashlaneSafariPage]()
    private var pagesBySafariPage = [SFSafariPage: DashlaneSafariPage]()
    
    private var lastTabId = 0
    private var toolbarItemIsEnabled = true
    var lastPage: DashlaneSafariPage? {
        didSet {
            DispatchQueue.main.async {
                self.scheduleNextTabsLookup()
            }
        }
    }
    private let messageDispatcher: AutofillMessageDispatcher
    private var tabsLookupTimer: Timer?
    
    private var pagesListeners = [ListenerType: Set<JSValue?>]()
    private let pagesListenersQueue = DispatchQueue(label: "pages.listeners", qos: .userInitiated)

    
    
    
    init(logger: Logger?,
         messageDispatcher: AutofillMessageDispatcher) {
        self.logger = logger
        self.messageDispatcher = messageDispatcher

        super.init()
        messageDispatcher.addObserver(on: .injected, listener: self, call: handleCommunication(_:))
    }
    
    deinit {
        messageDispatcher.removeObserver(for: .injected, listener: self)
    }
    
    private func handleCommunication(_ communication: Communication) {
        queue.async { [weak self] in
            guard let tabId = communication.body["tabId"] as? Int else {
                self?.logger?.error("unexpected tabId")
                return
            }
            
            guard let type = communication.body["type"] as? String else {
                self?.logger?.error("unexpected type")
                return
            }
            
            guard let data = communication.body["data"] as? [String: Any] else {
                self?.logger?.error("unexpected data")
                return
            }
            
            guard let page = self?.search(tabId: tabId) else {
                self?.logger?.error("page for tabId \(tabId) not found ")
                return
            }
            
            page.dashlaneMessageToWebPage(type, data, self?.logger)
        }
    }
    
    func search(tabId: Int) -> DashlaneSafariPage? {
        return pagesByTabId[tabId]
    }
    
    func search(page: SFSafariPage) -> DashlaneSafariPage? {
        return tabsQueue.sync {
            return pagesBySafariPage[page]
        }
    }

    func merge(page: SFSafariPage) -> DashlaneSafariPage {
        if let found = search(page: page) {
            return found
        } else {
            lastTabId += 1
            let created = DashlaneSafariPage(page: page, tabId: lastTabId, didUpdate: pageDidUpdate)
            tabsQueue.async {
                self.pagesByTabId[self.lastTabId] = created
                self.pagesBySafariPage[page] = created
            }
            return created
        }
    }
    
    private func pageDidUpdate(_ page: DashlaneSafariPage) {
        pagesListenersQueue.async {
            self.pagesListeners[.onUpdated]?.forEach {
                let args: [String: Any] = [
                    "tabId": page.tabId,
                    "changeInfo": ["status": "complete"]
                ]
                $0?.call(withArguments: [args as Any])
            }
        }
    }
    
            private func scheduleNextTabsLookup() {
        guard tabsLookupTimer == nil else {
            return
        }
        tabsLookupTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { timer in
            self.tabsLookupTimer?.invalidate()
            self.tabsLookupTimer = nil
            self.findAndRemoveClosedPages()
        })
    }
    
    private func findAndRemoveClosedPages() {
        pagesByTabId.forEach({ (tabId, page) in
                                    let optionalPage = page.page as SFSafariPage?
            guard let safariPage = optionalPage else {
                self.tabsQueue.async {
                    self.pagesByTabId.removeValue(forKey: tabId)
                    self.pagesBySafariPage = self.pagesBySafariPage.filter({ $0.value != page })
                }
                return
            }
            safariPage.getContainingTab(completionHandler: {
                tab in
                                                                let optionalTab = tab as SFSafariTab?
                if optionalTab == nil {
                    self.tabsQueue.async {
                        self.pagesByTabId.removeValue(forKey: tabId)
                        self.pagesBySafariPage.removeValue(forKey: safariPage)
                    }
                }
            })
            
        })
    }
    
        
    func getTabId(page: SFSafariPage) -> Int? {
        return self.search(page: page)?.tabId
    }
    
    func getTab(fromID: Int) -> DashlaneSafariPage? {
        return tabsQueue.sync { return self.pagesByTabId[fromID] }
    }

    func addListener(for type: ListenerType, value: JSValue) {
        pagesListenersQueue.async {
            self.pagesListeners[type, default: []].insert(value)
        }
    }
}

extension InjectedService: SFSafariExtensionHandling {
    
    public func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler { [unowned self] properties in
            self.queue.async { [weak self] in
                guard let self = self else { return }
                let page = self.merge(page: page)
                page.url = properties?.url?.absoluteString
                page.title = properties?.title
                self.lastPage = page
                if messageName == machineLearningMessageKey {
                    guard let info = userInfo else { return }
                    self.pagesListenersQueue.async {
                        self.pagesListeners[.onMessage]?.forEach {
                            $0?.call(withArguments: [info as Any, page.tabId])
                        }
                    }
                } else {
                    self.messageReceived(withName: messageName, from: page, userInfo: userInfo)
                }
            }
        }
    }
    
    private func messageReceived(withName messageName: String, from page: DashlaneSafariPage, userInfo: [String : Any]?) {
        guard let userInfo = userInfo else {
            logger?.error("userInfo not found")
            return
        }
        
        let body: [String: Any] = [
            "tabId": page.tabId,
            "type": messageName,
            "data": userInfo
        ]
        let communication = Communication(from: .injected, to: .background, subject: "injected", body: body)
        messageDispatcher.post(communication)
    }
}

extension DashlaneSafariPage {
    
    func dashlaneMessageToWebPage(_ type: String, _ message: [String: Any], _ logger: Logger?) {
        page.dispatchMessageToScript(withName: type, userInfo: message)
    }
}
