import Foundation

extension UserEvent {

public struct `GeneratePassword`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`hasDigits`: Bool, `hasLetters`: Bool, `hasSimilar`: Bool, `hasSymbols`: Bool, `length`: Int) {
self.hasDigits = hasDigits
self.hasLetters = hasLetters
self.hasSimilar = hasSimilar
self.hasSymbols = hasSymbols
self.length = length
}
public let hasDigits: Bool
public let hasLetters: Bool
public let hasSimilar: Bool
public let hasSymbols: Bool
public let length: Int
public let name = "generate_password"
}
}
