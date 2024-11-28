import CoreLocalization
import Foundation

private struct Card: Equatable {
  var lastDigits: String {
    if let lastDigitsGroup = type?.spacingPattern(for: number).last {
      return String(number.suffix(lastDigitsGroup))
    }
    return String(number.suffix(3))
  }
  let number: String
  var spacingPattern: CardType.SpacingPattern? {
    type?.spacingPattern(for: number)
  }
  private let `type`: CardType?

  init(number: String) {
    self.number = number
    self.type = CardType.for(cardNumber: number)
  }
}

private enum CardType: CaseIterable {
  typealias SpacingPattern = [Int]

  case americanExpress
  case chinaUnionPay
  case dinersClub
  case japaneseCreditBureau
  case maestro
  case masterCard
  case universalAirTravelPlan
  case visa

  private var issuerIdentificationNumber: [ClosedRange<Int>] {
    switch self {
    case .americanExpress:
      return [34...34, 37...37]
    case .chinaUnionPay:
      return [62...62]
    case .dinersClub:
      return [300...305, 309...309, 36...36, 38...39]
    case .japaneseCreditBureau:
      return [3528...3589]
    case .maestro:
      return [500000...509999, 560000...589999, 600000...699999]
    case .masterCard:
      return [51...55, 222100...272099]
    case .universalAirTravelPlan:
      return [1...1]
    case .visa:
      return [4...4]
    }
  }

  func spacingPattern(for cardNumber: String) -> SpacingPattern {
    switch self {
    case .americanExpress:
      guard cardNumber.count == 15 else { break }
      return [4, 6, 5]
    case .chinaUnionPay:
      switch cardNumber.count {
      case 16:
        return [4, 4, 4, 4]
      case 19:
        return [6, 13]
      default:
        break
      }
    case .dinersClub:
      switch cardNumber.count {
      case 14:
        return [4, 6, 4]
      case 16:
        return [4, 4, 4, 4]
      default:
        break
      }
    case .japaneseCreditBureau:
      guard cardNumber.count == 16 else { break }
      return [4, 4, 4, 4]
    case .maestro:
      switch cardNumber.count {
      case 13:
        return [4, 4, 5]
      case 15:
        return [4, 6, 5]
      case 16:
        return [4, 4, 4, 4]
      case 19:
        return [4, 4, 4, 4, 3]
      default:
        break
      }
    case .masterCard:
      guard cardNumber.count == 16 else { break }
      return [4, 4, 4, 4]
    case .universalAirTravelPlan:
      guard cardNumber.count == 15 else { break }
      return [4, 5, 6]
    case .visa:
      guard cardNumber.count == 16 else { break }
      return [4, 4, 4, 4]
    }

    return fallbackSpacingPattern(for: cardNumber)
  }

  private func fallbackSpacingPattern(for cardNumber: String) -> SpacingPattern {
    let defaultGrouping = 4
    let groups = Int(cardNumber.count / defaultGrouping)
    let suffix = Int(cardNumber.count % defaultGrouping)

    if suffix == 0 {
      return SpacingPattern(repeating: defaultGrouping, count: groups)
    } else {
      if suffix < 3 {
        let isUltimateGroupTooShort = suffix == 1
        var grouping = SpacingPattern(repeating: defaultGrouping, count: groups - 1)

        if isUltimateGroupTooShort {
          grouping.append(suffix + defaultGrouping - suffix + 1)
        } else {
          grouping.append(defaultGrouping - 1)
          grouping.append(suffix + 1)
        }

        return grouping
      }
      return SpacingPattern(repeating: defaultGrouping, count: groups) + [suffix]
    }
  }

  static func `for`(cardNumber: String) -> CardType? {
    for issuer in CardType.allCases {
      for identificationNumberRange in issuer.issuerIdentificationNumber {
        let prefixLength = String(identificationNumberRange.upperBound).count
        let cardNumberPrefix = Int(cardNumber.prefix(prefixLength))

        if let cardNumberPrefix, identificationNumberRange.contains(cardNumberPrefix) {
          return issuer
        }
      }
    }
    return nil
  }
}

struct CardNumberFormatStyle: AccessibleObfuscatedFormatStyle {
  let obfuscated: Bool

  func format(_ value: String) -> String {
    let card = Card(number: value)

    if obfuscated {
      guard let spacingPattern = card.spacingPattern,
        let lastPattern = spacingPattern.last
      else {
        return String(repeating: "•", count: card.number.count)
      }
      let obfuscatedPart =
        spacingPattern
        .dropLast()
        .map({ String(repeating: "•", count: $0) })
        .joined(separator: " ")
      return [obfuscatedPart, String(card.number.suffix(lastPattern))].joined(separator: " ")
    } else {
      guard let chunks = card.spacingPattern else { return card.number }
      return card.number.split(byChunks: chunks).joined(separator: " ")
    }
  }

  func accessibilityText(for value: String) -> String {
    if obfuscated {
      let card = Card(number: value)
      return L10n.Core.accessibilityCardNumberEndingWith(card.lastDigits)
    }
    return format(value)
  }
}

extension FormatStyle where Self == CardNumberFormatStyle {
  static func cardNumber(obfuscated: Bool) -> Self {
    CardNumberFormatStyle(obfuscated: obfuscated)
  }
}
