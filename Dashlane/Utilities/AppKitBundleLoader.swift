#if targetEnvironment(macCatalyst)
  import Foundation

  struct AppKitBundleLoader {

    static func load() -> AppKitBridgeProtocol {
      let bundleFileName = "AppKitBridgeBundle.bundle"
      guard let bundleURL = Bundle.main.builtInPlugInsURL?.appendingPathComponent(bundleFileName)
      else {
        preconditionFailure()
      }

      guard let bundle = Bundle(url: bundleURL) else {
        preconditionFailure("Bundle should exist")
      }

      let className = "AppKitBridgeBundle.AppKitBridge"
      guard let appKitBridgeClass = bundle.classNamed(className) as? AppKitBridgeProtocol.Type
      else {
        preconditionFailure("Cannot initialise \(className) from bundle")
      }

      let appKitBridge = appKitBridgeClass.init()

      return appKitBridge
    }
  }
#endif
