import Foundation

#if canImport(UIKit)
  import UIKit
#endif

public enum Platform: String, Encodable {
  case passwordManagerIphone = "server_iphone"
  case passwordManagerIpad = "server_ipad"
  case passwordManagerMac = "server_catalyst"

  public static var passwordManager: Platform {
    #if targetEnvironment(macCatalyst)
      return .passwordManagerMac
    #else
      let isIpad = UIDevice.current.userInterfaceIdiom == .pad
      return isIpad ? .passwordManagerIpad : .passwordManagerIphone
    #endif
  }
}
