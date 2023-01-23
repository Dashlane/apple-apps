import Foundation

extension UserEvent {

public struct `AutofillSuggest`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`autofillMessageTypeList`: [Definition.AutofillMessageType]? = nil, `isLoginPrefilled`: Bool? = nil, `isNativeApp`: Bool, `isPasswordPrefilled`: Bool? = nil, `isRestoredWebcard`: Bool? = nil, `isSuggestLastUnsaved`: Bool? = nil, `msToWebcard`: Int? = nil, `vaultTypeList`: [Definition.ItemType]? = nil, `webcardItemTotalCount`: Int? = nil, `webcardSaveOptions`: [Definition.WebcardSaveOptions]? = nil) {
self.autofillMessageTypeList = autofillMessageTypeList
self.isLoginPrefilled = isLoginPrefilled
self.isNativeApp = isNativeApp
self.isPasswordPrefilled = isPasswordPrefilled
self.isRestoredWebcard = isRestoredWebcard
self.isSuggestLastUnsaved = isSuggestLastUnsaved
self.msToWebcard = msToWebcard
self.vaultTypeList = vaultTypeList
self.webcardItemTotalCount = webcardItemTotalCount
self.webcardSaveOptions = webcardSaveOptions
}
public let autofillMessageTypeList: [Definition.AutofillMessageType]?
public let isLoginPrefilled: Bool?
public let isNativeApp: Bool
public let isPasswordPrefilled: Bool?
public let isRestoredWebcard: Bool?
public let isSuggestLastUnsaved: Bool?
public let msToWebcard: Int?
public let name = "autofill_suggest"
public let vaultTypeList: [Definition.ItemType]?
public let webcardItemTotalCount: Int?
public let webcardSaveOptions: [Definition.WebcardSaveOptions]?
}
}
