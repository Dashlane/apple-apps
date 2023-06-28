import Foundation
import SwiftTreats

public enum Gender: String, Codable, Defaultable, CaseIterable, Identifiable {
    public static let defaultValue: Gender = .male

    public var id: String {
        return self.rawValue
    }

    case male = "MALE"
    case female = "FEMALE"
}
