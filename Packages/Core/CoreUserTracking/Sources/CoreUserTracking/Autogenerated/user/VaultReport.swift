import Foundation

extension UserEvent {

public struct `VaultReport`: Encodable, UserEventProtocol {
public static let isPriority = true
public init(`darkWebAlertsActiveCount`: Int? = nil, `darkWebAlertsCount`: Int? = nil, `domainsWithoutAutofillCount`: Int? = nil, `passwordsCompromisedCount`: Int, `passwordsCompromisedThroughDarkWebCount`: Int? = nil, `passwordsExcludedCount`: Int, `passwordsProtectedWithMasterPasswordCount`: Int? = nil, `passwordsReusedCount`: Int, `passwordsSafeCount`: Int, `passwordsTotalCount`: Int, `passwordsWeakCount`: Int, `passwordsWithAutologinDisabledCount`: Int? = nil, `passwordsWithOtpCount`: Int, `scope`: Definition.Scope, `securityAlertsActiveCount`: Int? = nil, `securityAlertsCount`: Int? = nil, `securityScore`: Int? = nil) {
self.darkWebAlertsActiveCount = darkWebAlertsActiveCount
self.darkWebAlertsCount = darkWebAlertsCount
self.domainsWithoutAutofillCount = domainsWithoutAutofillCount
self.passwordsCompromisedCount = passwordsCompromisedCount
self.passwordsCompromisedThroughDarkWebCount = passwordsCompromisedThroughDarkWebCount
self.passwordsExcludedCount = passwordsExcludedCount
self.passwordsProtectedWithMasterPasswordCount = passwordsProtectedWithMasterPasswordCount
self.passwordsReusedCount = passwordsReusedCount
self.passwordsSafeCount = passwordsSafeCount
self.passwordsTotalCount = passwordsTotalCount
self.passwordsWeakCount = passwordsWeakCount
self.passwordsWithAutologinDisabledCount = passwordsWithAutologinDisabledCount
self.passwordsWithOtpCount = passwordsWithOtpCount
self.scope = scope
self.securityAlertsActiveCount = securityAlertsActiveCount
self.securityAlertsCount = securityAlertsCount
self.securityScore = securityScore
}
public let darkWebAlertsActiveCount: Int?
public let darkWebAlertsCount: Int?
public let domainsWithoutAutofillCount: Int?
public let name = "vault_report"
public let passwordsCompromisedCount: Int
public let passwordsCompromisedThroughDarkWebCount: Int?
public let passwordsExcludedCount: Int
public let passwordsProtectedWithMasterPasswordCount: Int?
public let passwordsReusedCount: Int
public let passwordsSafeCount: Int
public let passwordsTotalCount: Int
public let passwordsWeakCount: Int
public let passwordsWithAutologinDisabledCount: Int?
public let passwordsWithOtpCount: Int
public let scope: Definition.Scope
public let securityAlertsActiveCount: Int?
public let securityAlertsCount: Int?
public let securityScore: Int?
}
}
