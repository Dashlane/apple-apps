import Foundation

extension AnonymousEvent {

  public struct `AutofillSuggest`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `autofillMessageTypeList`: [Definition.AutofillMessageType]? = nil,
      `domain`: Definition.Domain,
      `isLoginPrefilled`: Bool? = nil, `isNativeApp`: Bool, `isPasswordPrefilled`: Bool? = nil,
      `isSuggestLastUnsaved`: Bool? = nil, `msToWebcard`: Int? = nil,
      `phishingRisk`: Definition.PhishingRisk? = nil, `vaultTypeList`: [Definition.ItemType]? = nil,
      `webcardItemTotalCount`: Int? = nil,
      `webcardSaveOptions`: [Definition.WebcardSaveOptions]? = nil
    ) {
      self.autofillMessageTypeList = autofillMessageTypeList
      self.domain = domain
      self.isLoginPrefilled = isLoginPrefilled
      self.isNativeApp = isNativeApp
      self.isPasswordPrefilled = isPasswordPrefilled
      self.isSuggestLastUnsaved = isSuggestLastUnsaved
      self.msToWebcard = msToWebcard
      self.phishingRisk = phishingRisk
      self.vaultTypeList = vaultTypeList
      self.webcardItemTotalCount = webcardItemTotalCount
      self.webcardSaveOptions = webcardSaveOptions
    }
    public let autofillMessageTypeList: [Definition.AutofillMessageType]?
    public let domain: Definition.Domain
    public let isLoginPrefilled: Bool?
    public let isNativeApp: Bool
    public let isPasswordPrefilled: Bool?
    public let isSuggestLastUnsaved: Bool?
    public let msToWebcard: Int?
    public let name = "autofill_suggest"
    public let phishingRisk: Definition.PhishingRisk?
    public let vaultTypeList: [Definition.ItemType]?
    public let webcardItemTotalCount: Int?
    public let webcardSaveOptions: [Definition.WebcardSaveOptions]?
  }
}
