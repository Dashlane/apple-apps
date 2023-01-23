import Foundation

extension UserEvent {

public struct `PerformAutofill`: Encodable, UserEventProtocol {
public static let isPriority = true
public init(`autofillMechanism`: Definition.AutofillMechanism, `autofillOrigin`: Definition.AutofillOrigin, `fieldsFilled`: Definition.FieldsFilled? = nil, `formTypeList`: [Definition.FormType]? = nil, `isAutologin`: Bool, `isManual`: Bool, `matchType`: Definition.MatchType, `mobileBrowserName`: String? = nil, `passwordFilledHealth`: Definition.CredentialSecurityStatus? = nil) {
self.autofillMechanism = autofillMechanism
self.autofillOrigin = autofillOrigin
self.fieldsFilled = fieldsFilled
self.formTypeList = formTypeList
self.isAutologin = isAutologin
self.isManual = isManual
self.matchType = matchType
self.mobileBrowserName = mobileBrowserName
self.passwordFilledHealth = passwordFilledHealth
}
public let autofillMechanism: Definition.AutofillMechanism
public let autofillOrigin: Definition.AutofillOrigin
public let fieldsFilled: Definition.FieldsFilled?
public let formTypeList: [Definition.FormType]?
public let isAutologin: Bool
public let isManual: Bool
public let matchType: Definition.MatchType
public let mobileBrowserName: String?
public let name = "perform_autofill"
public let passwordFilledHealth: Definition.CredentialSecurityStatus?
}
}
