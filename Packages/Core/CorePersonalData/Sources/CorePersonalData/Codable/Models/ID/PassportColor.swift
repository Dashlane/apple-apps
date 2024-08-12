import Foundation
import SwiftTreats

public enum PassportColor: String, Equatable, Defaultable, CaseIterable {
  public static let defaultValue: PassportColor = .navy

  case burgundy
  case red
  case navy
  case green
  case black

  public static func localized(from countryCode: String?) -> PassportColor {
    switch countryCode {
    case "FR", "LU":
      return .burgundy

    case "CH", "GB", "IE", "DE", "ES", "IT", "BE", "NL", "AT", "DK", "JP", "CN", "PL":
      return .red

    case "US", "CA", "BR", "IN", "AU":
      return .navy

    case "KR", "MA":
      return .green

    case "MX":
      return .black
    default:
      return .defaultValue
    }
  }
}
