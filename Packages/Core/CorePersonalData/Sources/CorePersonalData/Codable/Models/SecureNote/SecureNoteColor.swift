import Foundation
import SwiftTreats

public enum SecureNoteColor: String, Equatable, Codable, Defaultable, CaseIterable, Identifiable {
    public static let defaultValue: SecureNoteColor = .gray

    public var id: String {
        return rawValue
    }

    case blue = "BLUE"
    case purple = "PURPLE"
    case pink = "PINK"
    case red = "RED"
    case brown = "BROWN"
    case green = "GREEN"
    case orange = "ORANGE"
    case yellow = "YELLOW"
    case gray = "GRAY"
}
