import Foundation
import SwiftTreats

public struct TestAccount {
  public static let password = "_"
  public static let accountPrefix = "_"
}

extension Login {

  public var isTest: Bool {
    return self.email.lowercased().starts(with: TestAccount.accountPrefix)
  }

  public static func generateTest() -> String {
    let random = String.randomAlphanumeric(ofLength: 6)
    return "\(TestAccount.accountPrefix)\(random)_"
  }
}
