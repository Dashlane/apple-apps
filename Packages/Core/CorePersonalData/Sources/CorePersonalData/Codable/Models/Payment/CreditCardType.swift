import Foundation
import SwiftTreats

public enum CreditCardType: String, Codable, CaseIterable, Defaultable {
    public static let defaultValue: CreditCardType = .unknown

    case visa = "PAYMENT_TYPE_VISA"
    case chinaUnionPay = "PAYMENT_TYPE_CHINAUNIONPAY"
    case visaElectron = "PAYMENT_TYPE_VISAELECTRON"
    case masterCard = "PAYMENT_TYPE_MASTERCARD"
    case maestro = "PAYMENT_TYPE_MAESTRO"
    case amex = "PAYMENT_TYPE_AMEX"
    case discover = "PAYMENT_TYPE_DISCOVER"
    case dinersClub = "PAYMENT_TYPE_DINERSCLUB"
    case jcb = "PAYMENT_TYPE_JCB"
    case unknown = "PAYMENT_TYPE_UNKNOWN"

            init(cardNumber: String) {
        let filteredNumber = cardNumber.filter { $0.isNumber }
        guard filteredNumber.count >= 6 else {
            self = .unknown
            return
        }
        guard let iinPrefix = Int(filteredNumber[..<filteredNumber.index(filteredNumber.startIndex, offsetBy: 6)]) else {
            self = .unknown
            return
        }

                switch (iinPrefix, filteredNumber.count) {
        case (402_600...402_699, 16),
             (417500, 16),
             (450_800...450_899, 16),
             (484_400...484_499, 16),
             (491_300...491_399, 16),
             (491_700...491_799, 16):
                                                self = .visaElectron
        case (620_000...629_999, 16...19):
            self = .chinaUnionPay
        case (400_000...499_999, 16):
            self = .visa
        case (340_000...349_999, 15),
             (370_000...379_999, 15):
            self = .amex
        case (352_800...358_999, 16...19):
            self = .jcb
        case (510_000...559_999, 16),
             (222_100...272_099, 16):
            self = .masterCard
        case (501_800...501_899, 12...19),
             (502_000...502_099, 12...19),
             (503_800...503_899, 12...19),
             (630_400...630_499, 12...19),
             (675_900...675_999, 12...19),
             (676_100...676_199, 12...19),
             (676_300...676_399, 12...19):
            self = .maestro
        case (360_000...369_999, 14...19),
             (380_000...399_999, 16...19),
             (300_000...305_999, 14...19),
             (309_500...309_599, 16...19):
            self = .dinersClub
        case (640_000...659_999, 16...19),
             (601_100...601_199, 16...19),
             (622_126...622_925, 16...19),
             (624_000...626_999, 16...19),
             (628_200...628_899, 16...19):
            self = .discover
        default:
            self = .unknown
        }
    }
}
