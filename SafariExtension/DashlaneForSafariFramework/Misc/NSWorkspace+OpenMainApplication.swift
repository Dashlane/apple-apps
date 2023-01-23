import Cocoa
import SwiftTreats
import DashTypes

extension NSWorkspace {
    private func mainApplicationURL() -> URL? {
        let mainApplicationBundleID = Application.mainApplicationBundleIdentifier
        guard let mainApplicationURL = urlForApplication(withBundleIdentifier: mainApplicationBundleID) else {
            assertionFailure("No main app?")
            return nil
        }
        return mainApplicationURL
    }
    
    func openMainApplication(urls: [URL] = []) {
        guard let mainApplicationURL = self.mainApplicationURL() else {
            return
        }
        open(urls, withApplicationAt: mainApplicationURL, configuration: .init(), completionHandler: nil)
    }
    
    func openMainApplication(url: URL) {
        openMainApplication(urls: [url])
    }
    
    func openDashlane(with url: URL) {
        guard let mainApplicationURL = self.mainApplicationURL() else {
            return
        }
        
        open([url],
             withApplicationAt: mainApplicationURL,
             configuration: .init(),
             completionHandler: nil)
    }
}
