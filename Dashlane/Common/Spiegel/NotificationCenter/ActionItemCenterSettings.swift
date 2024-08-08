import DashlaneSettings
import Settings

final class ActionItemCenterSettings: NSObject {

  enum SettingsKeys: String {
    case localAccountCreationDate = "localAccountCreationDateSettingskey"
  }

  private var settings: Settings! {
    guard let settings = SettingsManager.sharedInstance[userLogin] else {
      preconditionFailure("Settings not available")
    }
    return settings
  }

  var localAccountCreationDate: Date? {
    get {
      return settings.value(for: SettingsKeys.localAccountCreationDate.rawValue) ?? nil
    }
    set {
      settings.set(value: newValue, forIdentifier: SettingsKeys.localAccountCreationDate.rawValue)
    }
  }

  override init() {
    super.init()
    registerSettings()
  }

  public func registerSettings() {
    if !settings.register.isRegistered(identifier: SettingsKeys.localAccountCreationDate.rawValue) {
      let settingRegistration = SettingRegistration(
        identifier: SettingsKeys.localAccountCreationDate.rawValue,
        type: Date.self)
      try! settings.register.append(settingRegistration)
    }
  }
}
