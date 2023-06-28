import Foundation

extension Definition {

public enum `SignupFlowStep`: String, Encodable {
case `createMasterPassword` = "create_master_password"
case `enterEmailAddress` = "enter_email_address"
case `installExtension` = "install_extension"
case `loginToAccount` = "login_to_account"
case `verifyEmail` = "verify_email"
}
}