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
      return Color(asset: Asset.creditCardSilver)
    case .red:
      return Color(asset: Asset.creditCardRed)
    case .orange:
      return Color(asset: Asset.creditCardOrange)
    case .gold:
      return Color(asset: Asset.creditCardGold)
    case .green:
      return Color(asset: Asset.creditCardGreen)
    case .darkGreen:
      return Color(asset: Asset.creditCardDarkGreen)
    case .blue:
      return Color(asset: Asset.creditCardBlue)
    case .darkBlue:
      return Color(asset: Asset.creditCardDarkBlue)
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

  public static let coloredLogoColors = allCases.filter { $0.isLight }.map { $0.color }
}
