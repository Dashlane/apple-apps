import Foundation

extension Definition {

public enum `OnboardingTask`: String, Encodable {
case `addFirstLogin` = "add_first_login"
case `getMobileApp` = "get_mobile_app"
case `tryAutofill` = "try_autofill"
}
}