public protocol PasswordGeneratorProtocol {
  func generate() -> String
}

public struct FakePasswordGenerator: PasswordGeneratorProtocol {
  public func generate() -> String {
    return "_"
  }
}

extension PasswordGeneratorProtocol where Self == FakePasswordGenerator {
  public static var mock: PasswordGeneratorProtocol {
    FakePasswordGenerator()
  }
}
