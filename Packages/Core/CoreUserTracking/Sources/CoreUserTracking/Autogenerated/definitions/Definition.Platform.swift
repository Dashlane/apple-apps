import Foundation

extension Definition {

public enum `Platform`: String, Encodable {
case `android`
case `authenticatorAndroid` = "authenticator_android"
case `authenticatorIos` = "authenticator_ios"
case `catalyst`
case `ios`
case `saex`
case `safari`
case `tac`
case `web`
}
}