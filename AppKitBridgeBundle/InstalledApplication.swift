import Foundation
import AppKit

@objc class InstalledApplication: NSObject, InstalledApplicationProtocol {
    
    func defaultBrowser() -> String? {
        guard let url = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "_")!) else {
            assertionFailure()
            return nil
        }
        let applicationSuffix = ".app"
        var lastPathComponent = url.lastPathComponent
        if lastPathComponent.hasSuffix(applicationSuffix) {
            lastPathComponent.removeLast(applicationSuffix.count)
        }
        return lastPathComponent
    }

    func hasApplication(withBundleIdentifier: String) -> Bool {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: withBundleIdentifier) != nil
    }

    func hasDashlaneLegacy() -> Bool {
        let identifiers = [
            "com.dashlane.Dashlane", 
            "com.dashlane.mac.Dashlane" 
        ]

        let installed = identifiers.first(where: { hasApplication(withBundleIdentifier: $0) })
        return installed != nil
    }
}
