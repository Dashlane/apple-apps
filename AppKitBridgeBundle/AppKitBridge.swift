import AppKit

class AppKitBridge: NSObject, AppKitBridgeProtocol {

  required override init() {

  }

  let runningApplication: RunningApplicationProtocol = RunningApplication()
  let installedApplication: InstalledApplicationProtocol = InstalledApplication()
  let applicationOpener: ApplicationOpenerProtocol = ApplicationOpener()
}
