import Foundation
import LocalAuthentication

#if canImport(UIKit)
  import UIKit
#endif

public struct Device {
  public static func localizedName() -> String {
    #if canImport(UIKit)
      return UIDevice.current.name
    #else
      return Self.hardwareName
    #endif
  }

  public static func uniqueIdentifier() -> String {
    #if canImport(UIKit)
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
    #if canImport(UIKit)
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
    case .opticID:
      return .opticId
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
  public enum Kind {
    case pad
    case phone
    case vision
    case mac
    case watch
  }

  private static func `is`(exact kind: Kind) -> Bool {
    #if targetEnvironment(macCatalyst) || os(macOS)
      return if case .mac = kind {
        true
      } else {
        false
      }
    #elseif os(visionOS)
      return if case .vision = kind {
        true
      } else {
        false
      }
    #elseif os(watchOS)
      return if case .watch = kind {
        true
      } else {
        false
      }
    #else
      return switch kind {
      case .pad:
        UIDevice.current.userInterfaceIdiom == .pad
      case .phone:
        UIDevice.current.userInterfaceIdiom == .phone
      case .vision, .mac, .watch:
        false
      }
    #endif
  }

  public static func `is`(_ oneOf: Kind...) -> Bool {
    return oneOf.contains(where: self.is(exact:))
  }

  public static func `is`(not oneOf: Kind...) -> Bool {
    return oneOf.contains(where: self.is(exact:)) == false
  }

  public static var kind: Kind {
    #if targetEnvironment(macCatalyst) || os(macOS)
      return .mac
    #elseif os(visionOS)
      return .vision
    #elseif os(watchOS)
      return .watch
    #else
      switch UIDevice.current.userInterfaceIdiom {
      case .pad:
        return .pad
      case .phone:
        return .phone
      default:
        return .phone
      }
    #endif
  }
}
