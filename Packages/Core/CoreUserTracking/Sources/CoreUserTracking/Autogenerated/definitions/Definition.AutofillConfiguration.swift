import Foundation

extension Definition {

  public enum `AutofillConfiguration`: String, Encodable, Sendable {
    case `autofillDisabled` = "autofill_disabled"
    case `autofillEnabled` = "autofill_enabled"
    case `autologinDisabled` = "autologin_disabled"
    case `autologinEnabled` = "autologin_enabled"
    case `loginAndPasswordsOnly` = "login_and_passwords_only"
    case `oneClickFormFillDisabled` = "one_click_form_fill_disabled"
    case `oneClickFormFillEnabled` = "one_click_form_fill_enabled"
    case `phishingAlertsDisabled` = "phishing_alerts_disabled"
    case `phishingAlertsEnabled` = "phishing_alerts_enabled"
  }
}
