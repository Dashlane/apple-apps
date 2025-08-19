import CorePersonalData
import CoreTypes
import Foundation
import SwiftUI

extension CreditCard {
  public var subtitleImage: SwiftUI.Image? {
    self.asset
  }

  public var subtitleFont: Font? {
    return Font.caption.monospaced()
  }
}

extension CreditCard {
  fileprivate var asset: SwiftUI.Image? {
    guard let type = self.type else {
      return nil
    }
    switch type {
    case .amex:
      return Image(.CreditCardsTypes.amex)
    case .dinersClub:
      return Image(.CreditCardsTypes.dinersclub)
    case .visa:
      return Image(.CreditCardsTypes.visa)
    case .discover:
      return Image(.CreditCardsTypes.discover)
    case .masterCard:
      return Image(.CreditCardsTypes.mastercard)
    case .jcb:
      return Image(.CreditCardsTypes.jcb)
    case .chinaUnionPay,
      .visaElectron,
      .maestro,
      .unknown:
      return nil
    }
  }
}
