import Foundation

extension Definition {

  public enum `AutofillMechanism`: String, Encodable, Sendable {
    case `androidAccessibility` = "android_accessibility"
    case `androidAutofillApi` = "android_autofill_api"
    case `iosTachyon` = "ios_tachyon"
    case `web`
  }
}
