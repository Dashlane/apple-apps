import Foundation

public struct DiagnosticMode {
  private static let settingsKey: String = "settings_diagnostic_mode"

  public static var isEnabled: Bool {
    UserDefaults.standard.bool(forKey: settingsKey)
  }
}

public struct SafeMode {
  private static let settingsKey: String = "settings_safe_mode"

  public static var isEnabled: Bool {
    UserDefaults.standard.bool(forKey: settingsKey)
  }
}
