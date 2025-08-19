import Foundation

extension Definition {

  public enum `PriorityPage`: String, Encodable, Sendable {
    case `accountCreationCreateAccount` = "account_creation/create_account"
    case `accountCreationCreateMasterPassword` = "account_creation/create_master_password"
    case `accountCreationEmail` = "account_creation/email"
    case `accountCreationTermsServices` = "account_creation/terms_services"
    case `loginEmail` = "login/email"
    case `loginToken` = "login/token"
    case `loginTokenAuthenticator` = "login/token/authenticator"
    case `loginTokenEmail` = "login/token/email"
    case `onboarding`
    case `onboardingTrustScreens` = "onboarding/trust_screens"
    case `toolsNewDevice` = "tools/new_device"
    case `unlockBiometric` = "unlock/biometric"
    case `unlockMp` = "unlock/mp"
    case `unlockPin` = "unlock/pin"
  }
}
