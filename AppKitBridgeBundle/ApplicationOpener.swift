import AppKit

@objc class ApplicationOpener: NSObject, ApplicationOpenerProtocol {
    func open(url: URL, inApplicationWithBundleIdentifier bundleId: String) {
        guard let application = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return
        }
        NSWorkspace.shared.open([url],
                                withApplicationAt: application,
                                configuration: .init(),
                                completionHandler:nil)
    }

    func openApplication(withBundleIdentifier bundleId: String) {
        guard let application = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return
        }
        NSWorkspace.shared.openApplication(at: application,
                                           configuration: .init(), completionHandler: nil)
    }
}
