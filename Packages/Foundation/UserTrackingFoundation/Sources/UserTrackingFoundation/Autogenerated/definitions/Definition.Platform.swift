import Foundation

extension Definition {

  public enum `Platform`: String, Encodable, Sendable {
    case `android`
    case `authenticatorAndroid` = "authenticator_android"
    case `authenticatorIos` = "authenticator_ios"
    case `catalyst`
    case `ios`
    case `saex`
    case `safari`
    case `tac`
    case `wearableAndroid` = "wearable_android"
    case `wearableIos` = "wearable_ios"
    case `web`
  }
}
