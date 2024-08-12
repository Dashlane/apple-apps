import Foundation

@objc(AppKitBridgeProtocol)
protocol AppKitBridgeProtocol: NSObjectProtocol {

  init()

  var runningApplication: RunningApplicationProtocol { get }
  var installedApplication: InstalledApplicationProtocol { get }
  var applicationOpener: ApplicationOpenerProtocol { get }

}

@objc
protocol RunningApplicationProtocol {
  func isSafariRunning() -> Bool
  func isApplicationRunning(identifier: String) -> Bool
}

@objc
protocol InstalledApplicationProtocol {
  func defaultBrowser() -> String?
  func hasApplication(withBundleIdentifier: String) -> Bool
  func hasDashlaneLegacy() -> Bool
}

@objc
protocol ApplicationOpenerProtocol {
  func openApplication(withBundleIdentifier: String)
  func open(url: URL, inApplicationWithBundleIdentifier: String)
}

private class FakeRunningApplication: RunningApplicationProtocol {
  func isSafariRunning() -> Bool { false }
  func isApplicationRunning(identifier: String) -> Bool { false }
}
private class FakeInstalledApplication: InstalledApplicationProtocol {
  func defaultBrowser() -> String? { nil }
  func hasApplication(withBundleIdentifier: String) -> Bool { false }
  func hasDashlaneLegacy() -> Bool { false }
}

private class FakeApplicationOpener: ApplicationOpenerProtocol {
  func openApplication(withBundleIdentifier: String) {}
  func open(url: URL, inApplicationWithBundleIdentifier: String) {}
}

final class FakeAppKitBridge: NSObject, AppKitBridgeProtocol {
  var runningApplication: RunningApplicationProtocol {
    FakeRunningApplication()
  }

  var installedApplication: InstalledApplicationProtocol {
    FakeInstalledApplication()
  }

  var applicationOpener: ApplicationOpenerProtocol {
    FakeApplicationOpener()
  }
}
