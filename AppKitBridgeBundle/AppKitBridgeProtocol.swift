import Foundation

@objc(AppKitBridgeProtocol)
protocol AppKitBridgeProtocol: NSObjectProtocol {

    init()

    var runningApplication: RunningApplicationProtocol { get }
    var installedApplication: InstalledApplicationProtocol { get }
    var applicationOpener: ApplicationOpenerProtocol { get }

    }

@objc protocol RunningApplicationProtocol {
    func isSafariRunning() -> Bool
    func isApplicationRunning(identifier: String) -> Bool
}

@objc protocol InstalledApplicationProtocol {
    func defaultBrowser() -> String?
    func hasApplication(withBundleIdentifier: String) -> Bool
    func hasDashlaneLegacy() -> Bool
}

@objc protocol ApplicationOpenerProtocol {
    func openApplication(withBundleIdentifier: String)
    func open(url: URL, inApplicationWithBundleIdentifier: String)
}


