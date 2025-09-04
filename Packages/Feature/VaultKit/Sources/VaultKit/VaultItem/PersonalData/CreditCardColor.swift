import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension CreditCardColor {
  public var color: Color {
    switch self {
    case .black:
      return .ds.container.agnostic.inverse.standard
    case .silver, .white:
      return Color(.creditCardSilver)
    case .red:
      return Color(.creditCardRed)
    case .orange:
      return Color(.creditCardOrange)
    case .gold:
      return Color(.creditCardGold)
    case .green:
      return Color(.creditCardGreen)
    case .darkGreen:
      return Color(.creditCardDarkGreen)
    case .blue:
      return Color(.creditCardBlue)
    case .darkBlue:
      return Color(.creditCardDarkBlue)
    }
  }

  public var isLight: Bool {
    switch self {
    case .silver, .white:
      return true
    default:
      return false
    }
  }
}
