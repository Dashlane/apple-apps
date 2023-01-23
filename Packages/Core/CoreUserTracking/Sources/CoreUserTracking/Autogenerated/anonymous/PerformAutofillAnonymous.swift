import Foundation

extension AnonymousEvent {

public struct `PerformAutofill`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`autofillMechanism`: Definition.AutofillMechanism, `autofillOrigin`: Definition.AutofillOrigin, `domain`: Definition.Domain, `fieldsFilled`: Definition.FieldsFilled? = nil, `formTypeList`: [Definition.FormType]? = nil, `isAutologin`: Bool, `isManual`: Bool, `isNativeApp`: Bool, `matchType`: Definition.MatchType, `mobileBrowserName`: String? = nil, `passwordFilledHealth`: Definition.CredentialSecurityStatus? = nil) {
self.autofillMechanism = autofillMechanism
self.autofillOrigin = autofillOrigin
self.domain = domain
self.fieldsFilled = fieldsFilled
self.formTypeList = formTypeList
self.isAutologin = isAutologin
self.isManual = isManual
self.isNativeApp = isNativeApp
self.matchType = matchType
self.mobileBrowserName = mobileBrowserName
self.passwordFilledHealth = passwordFilledHealth
}
public let autofillMechanism: Definition.AutofillMechanism
public let autofillOrigin: Definition.AutofillOrigin
public let domain: Definition.Domain
public let fieldsFilled: Definition.FieldsFilled?
public let formTypeList: [Definition.FormType]?
public let isAutologin: Bool
public let isManual: Bool
public let isNativeApp: Bool
public let matchType: Definition.MatchType
public let mobileBrowserName: String?
public let name = "perform_autofill"
public let passwordFilledHealth: Definition.CredentialSecurityStatus?
}
}
