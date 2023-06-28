import Foundation
import ImportKit
import DashTypes

private struct Detector: LastpassDetector {

    let appServices: AppServicesContainer

    var isLastpassInstalled: Bool {
#if targetEnvironment(macCatalyst)
        return appServices.appKitBridge.installedApplication.hasApplication(withBundleIdentifier: "com.lastpass.lastpassmacdesktop")
#else
        return false
#endif
    }
}

extension SessionServicesContainer: LastpassDetectorContainer {
    var lastpassDetector: LastpassDetector {
        Detector(appServices: appServices)
    }
}
