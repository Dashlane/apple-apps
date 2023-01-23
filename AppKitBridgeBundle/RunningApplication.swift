import AppKit

@objc class RunningApplication: NSObject, RunningApplicationProtocol {
    func isSafariRunning() -> Bool {
        isApplicationRunning(identifier: "com.apple.Safari") || isApplicationRunning(identifier: "com.apple.SafariTechnologyPreview")
    }
    
    func isApplicationRunning(identifier: String) -> Bool {
        NSRunningApplication.runningApplications(withBundleIdentifier: identifier).first != nil
    }
}
