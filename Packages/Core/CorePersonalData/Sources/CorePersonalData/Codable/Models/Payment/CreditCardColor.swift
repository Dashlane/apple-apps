import Foundation
import SwiftTreats

public enum CreditCardColor: String, Equatable, Codable, Defaultable, CaseIterable, Identifiable {
    public static let defaultValue: CreditCardColor = .blue

    public var id: String {
        return rawValue
    }
    
    case black = "BLACK"
    case silver = "SILVER"
    case white = "WHITE"
    case red = "RED"
    case orange = "ORANGE"
    case gold = "GOLD"
    case green = "GREEN_1"
    case darkGreen = "GREEN_2"
    case blue = "BLUE_1"
    case darkBlue = "BLUE_2"
}

