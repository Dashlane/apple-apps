import CorePersonalData
import DashTypes
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
      return Image(asset: Asset.amex)
    case .dinersClub:
      return Image(asset: Asset.dinersclub)
    case .visa:
      return Image(asset: Asset.visa)
    case .discover:
      return Image(asset: Asset.discover)
    case .masterCard:
      return Image(asset: Asset.mastercard)
    case .jcb:
      return Image(asset: Asset.jcb)
    case .chinaUnionPay,
      .visaElectron,
      .maestro,
      .unknown:
      return nil
    }
  }
}
