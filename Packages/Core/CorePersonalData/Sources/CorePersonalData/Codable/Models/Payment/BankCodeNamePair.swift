import Foundation

public struct BankCodeNamePair: CodeNamePair, Codable, Hashable, Identifiable {
  public var id: String {
    return code
  }

  public static let codeFormat: CodeFormat = .bank
  public let code: String
  public let name: String
  public init(code: String, name: String) {
    self.code = code
    self.name = name
  }
}

extension BankCodeNamePair: SearchValueConvertible {
  public var searchValue: String? {
    return name
  }
}
