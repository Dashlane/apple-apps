import Foundation

extension Definition {

  public enum `ProfilingFamiliarityPossibleAnswers`: String, Encodable, Sendable {
    case `notFamiliarAtAll` = "not_familiar_at_all"
    case `notVeryFamiliar` = "not_very_familiar"
    case `somewhatFamiliar` = "somewhat_familiar"
    case `superFamiliar` = "super_familiar"
    case `veryFamiliar` = "very_familiar"
  }
}
