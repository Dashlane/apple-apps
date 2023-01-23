import Cocoa

extension NSWorkspace {
    
    func isApplicationRunning(identifier: String) -> Bool {
        NSRunningApplication.runningApplications(withBundleIdentifier: identifier).first != nil
    }
    
    func open(_ url: URL,
              completion: @escaping (_ opened: Bool) -> Void) {
        guard let applicationURL = urlForApplication(toOpen: url) else {
            completion(false)
            return
        }
        open([url],
             withApplicationAt: applicationURL,
             configuration: .init()) { (application, error) in
            completion(error == nil)
        }
    }
    
    func openInSafari(_ url: URL) {
        let safariBundleIdentifier = "com.apple.Safari"
        guard let safariURL = urlForApplication(withBundleIdentifier: safariBundleIdentifier) else {
            assertionFailure("No Safari?")
            return
        }
        open([url],
             withApplicationAt: safariURL,
             configuration: .init(),
             completionHandler: nil)
        
        if let safari = runningApplications.first(where: { $0.bundleIdentifier == safariBundleIdentifier }) {
            safari.activate(options: .activateIgnoringOtherApps)
        }
    }
}
