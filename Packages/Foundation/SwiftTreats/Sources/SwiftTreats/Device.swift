#if canImport(UIKit)
  import Foundation
  import LocalAuthentication
  import UIKit

  public struct Device {
    public static func localizedName() -> String {
      return UIDevice.current.name
    }

    public static func uniqueIdentifier() -> String {
      #if os(iOS)
        guard let serialNumber = UIDevice.current.identifierForVendor?.uuidString else {
          return UUID().uuidString.onlyAlphanumeric()
        }

        let identifier: String = serialNumber
        return identifier.onlyAlphanumeric()
      #else
        return UUID().uuidString.onlyAlphanumeric()
      #endif
    }

    public static var name: String {
      #if os(iOS)
        return UIDevice.current.name
      #else
        return Self.hardwareName
      #endif
    }

    public static var hardwareName: String = {
      DeviceHardware.name
    }()

    public static var biometryType: Biometry? {
      let context = LAContext()
      guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
        return nil
      }
      switch context.biometryType {
      case .touchID:
        return .touchId
      case .faceID:
        return .faceId
      case .none: fallthrough
      @unknown default:
        return nil
      }
    }

    public static var currentBiometryDisplayableName: String {
      return Device.biometryType?.displayableName ?? ""
    }

    public static var isDeviceProtected: Bool {
      let context = LAContext()
      guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
        return false
      }
      return true
    }

    public static func localizedStringWithCurrentBiometry(key: String) -> String {
      return String(format: NSLocalizedString(key, comment: ""), currentBiometryDisplayableName)
    }

    public static var systemVersion: String {
      #if targetEnvironment(macCatalyst) || os(macOS)
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        return
          "OS_X_\(systemVersion.majorVersion)_\(systemVersion.minorVersion)_\(systemVersion.patchVersion)"
      #else
        return UIDevice.current.systemVersion
      #endif
    }
  }

  extension Device {
    #if os(iOS)
      static var isIpadOrMac: Bool {
        UIDevice.current.userInterfaceIdiom.isIpadOrMac
      }
    #elseif os(macOS)
      static var isIpadOrMac: Bool { return true }
    #endif

    public static var isIpad: Bool {
      #if targetEnvironment(macCatalyst) || !os(iOS)
        return false
      #else
        return isIpadOrMac
      #endif
    }

    public static var isMac: Bool {
      #if targetEnvironment(macCatalyst) || os(macOS)
        return true
      #else
        return false
      #endif
    }
  }
#endif
