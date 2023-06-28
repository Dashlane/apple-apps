import Foundation

extension Definition {

public enum `AutofillMessageType`: String, Encodable {
case `appMetaIncorrectSignature` = "app_meta_incorrect_signature"
case `duplicateRisk` = "duplicate_risk"
case `freeAccountPasswordLimitReached` = "free_account_password_limit_reached"
case `httpUnsecureWebsite` = "http_unsecure_website"
case `knownIncorrectSignature` = "known_incorrect_signature"
case `knownSourceAccountFillMismatch` = "known_source_account_fill_mismatch"
case `loginAccountPasswordGeneration` = "login_account_password_generation"
case `oneSignatureUnknown` = "one_signature_unknown"
case `potentialPhishingRisk` = "potential_phishing_risk"
case `unknownSourceAccountFillMismatch` = "unknown_source_account_fill_mismatch"
case `unsecureIframe` = "unsecure_iframe"
case `unsecureIframeSandbox` = "unsecure_iframe_sandbox"
}
}