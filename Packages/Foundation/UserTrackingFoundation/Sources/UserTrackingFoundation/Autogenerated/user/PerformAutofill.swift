import Foundation

extension UserEvent {

  public struct `PerformAutofill`: Encodable, UserEventProtocol {
    public static let isPriority = true
    public init(
      `autofillMechanism`: Definition.AutofillMechanism,
      `autofillOrigin`: Definition.AutofillOrigin,
      `credentialFilledItemId`: String? = nil, `fieldsFilled`: Definition.FieldsFilled? = nil,
      `formTypeList`: [Definition.FormType]? = nil, `isAutologin`: Bool, `isManual`: Bool,
      `itemSource`: Definition.ItemSource? = nil, `matchType`: Definition.MatchType,
      `mobileBrowserName`: String? = nil,
      `passwordFilledHealth`: Definition.CredentialSecurityStatus? = nil,
      `space`: Definition.Space? = nil
    ) {
      self.autofillMechanism = autofillMechanism
      self.autofillOrigin = autofillOrigin
      self.credentialFilledItemId = credentialFilledItemId
      self.fieldsFilled = fieldsFilled
      self.formTypeList = formTypeList
      self.isAutologin = isAutologin
      self.isManual = isManual
      self.itemSource = itemSource
      self.matchType = matchType
      self.mobileBrowserName = mobileBrowserName
      self.passwordFilledHealth = passwordFilledHealth
      self.space = space
    }
    public let autofillMechanism: Definition.AutofillMechanism
    public let autofillOrigin: Definition.AutofillOrigin
    public let credentialFilledItemId: String?
    public let fieldsFilled: Definition.FieldsFilled?
    public let formTypeList: [Definition.FormType]?
    public let isAutologin: Bool
    public let isManual: Bool
    public let itemSource: Definition.ItemSource?
    public let matchType: Definition.MatchType
    public let mobileBrowserName: String?
    public let name = "perform_autofill"
    public let passwordFilledHealth: Definition.CredentialSecurityStatus?
    public let space: Definition.Space?
  }
}
