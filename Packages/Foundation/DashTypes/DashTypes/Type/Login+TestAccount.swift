import Foundation
import SwiftTreats

public struct TestAccount {
    public static let password = "Dashlane12"
    public static let accountPrefix = "_"
}

public extension Login {
    
    var isTest: Bool {
        return self.email.lowercased().starts(with: TestAccount.accountPrefix)
    }
    
    static func generateTest() -> String {
        let random = String.randomAlphanumeric(ofLength: 6)
        return "\(TestAccount.accountPrefix)\(random)_"
    }
}
