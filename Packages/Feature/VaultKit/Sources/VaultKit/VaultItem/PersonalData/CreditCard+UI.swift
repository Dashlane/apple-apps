import Foundation
import CorePersonalData
import SwiftUI
import CoreSpotlight
import CoreLocalization

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
            return L10n.Core.kwPaymentMeanCreditCardIOS
        }
        return name
    }

    public var localizedSubtitle: String {
        if cardNumber.isEmpty {
            return L10n.Core.KWIDCardIOS.number
        }
        
        return "••••\(cardNumber.suffix(4)) \(subtitleDateString ?? "")"
    }
    
    private var subtitleDateString: String? {
        guard let date = editableExpireDate else { return nil }
        return CreditCard.expireDateSubtitleFormatter.string(from: date)
    }

    public static var localizedName: String {
        L10n.Core.kwPaymentMeanCreditCardIOS
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwPaymentMeanCreditCardIOS
    }

    public static var nativeMenuAddTitle: String {
        L10n.Core.addCreditCard
    }

        public var logData: VaultItemUsageLogData {
        VaultItemUsageLogData(country: country?.code)
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
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.black

        case .silver:
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.silver

        case .white:
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.white

        case .red:
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.red

        case .orange:
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.orange

        case .gold:
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.gold

        case .green:
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.green1

        case .darkGreen:
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.green2

        case .blue:
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.blue1

        case .darkBlue:
            return L10n.Core.KWPaymentMeanCreditCardIOS.Color.blue2
        }
    }
}

