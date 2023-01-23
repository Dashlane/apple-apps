import Foundation

extension AnonymousEvent {

public struct `AutofillChooseGeneratedPassword`: Encodable, AnonymousEventProtocol {
public static let isPriority = false
public init(`domain`: Definition.Domain, `hasDigits`: Bool, `hasLetters`: Bool, `hasPwgDefaultSettings`: Bool? = nil, `hasSimilar`: Bool, `hasSymbols`: Bool, `isNativeApp`: Bool? = nil, `length`: Int) {
self.domain = domain
self.hasDigits = hasDigits
self.hasLetters = hasLetters
self.hasPwgDefaultSettings = hasPwgDefaultSettings
self.hasSimilar = hasSimilar
self.hasSymbols = hasSymbols
self.isNativeApp = isNativeApp
self.length = length
}
public let domain: Definition.Domain
public let hasDigits: Bool
public let hasLetters: Bool
public let hasPwgDefaultSettings: Bool?
public let hasSimilar: Bool
public let hasSymbols: Bool
public let isNativeApp: Bool?
public let length: Int
public let name = "autofill_choose_generated_password"
}
}
