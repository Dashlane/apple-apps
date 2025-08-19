import CoreLocalization
import CorePersonalData
import CoreSpotlight
import Foundation
import SwiftUI

extension CreditCard: VaultItem {
  public var enumerated: VaultItemEnumeration {
    .creditCard(self)
  }

  public var editableExpireDate: Date? {
    get {
      return expiryDate
    }
    set {
      if let newValue = newValue {
        let calendar = Calendar.current
        expireYear = calendar.component(.year, from: newValue)
        expireMonth = calendar.component(.month, from: newValue)
      } else {
        expireYear = nil
        expireMonth = nil
      }
    }
  }

  public static var expireDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/yyyy"
    return formatter
  }

  public static var expireDateSubtitleFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/yy"
    return formatter
  }

  public var localizedTitle: String {
    guard !name.isEmpty else {
      if let bank = bank, !bank.name.isEmpty {
        return bank.name
      }
      return CoreL10n.kwPaymentMeanCreditCardIOS
    }
    return name
  }

  public var localizedSubtitle: String {
    if cardNumber.isEmpty {
      return CoreL10n.KWIDCardIOS.number
    }

    return "••••\(cardNumber.suffix(4)) \(subtitleDateString ?? "")"
  }

  private var subtitleDateString: String? {
    guard let date = editableExpireDate else { return nil }
    return CreditCard.expireDateSubtitleFormatter.string(from: date)
  }

  public static var localizedName: String {
    CoreL10n.kwPaymentMeanCreditCardIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwPaymentMeanCreditCardIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addCreditCard
  }
}

extension CreditCard: CopiablePersonalData {
  public var valueToCopy: String {
    return cardNumber
  }

  public var fieldToCopy: DetailFieldType {
    return .cardNumber
  }
}

extension CreditCardColor {
  public var localizedName: String {
    switch self {
    case .black:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.black

    case .silver:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.silver

    case .white:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.white

    case .red:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.red

    case .orange:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.orange

    case .gold:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.gold

    case .green:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.green1

    case .darkGreen:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.green2

    case .blue:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.blue1

    case .darkBlue:
      return CoreL10n.KWPaymentMeanCreditCardIOS.Color.blue2
    }
  }
}
