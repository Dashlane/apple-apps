import Foundation
import CoreLocalization
import CorePersonalData

public extension L10n.Core.KWBankStatementIOS {
    static func bicFieldTitle(for variant: BICVariant) -> String {
        switch variant {
        case .bic:
            return bankAccountBIC
        case .routingNumber:
            return routingNumber
        case .sortcode:
            return bankAccountSortCode
        }
    }

    static func ibanFieldTitle(for variant: IBANVariant) -> String {
        switch variant {
        case .account:
            return accountNumber
        case .clabe:
            return bankAccountClabe
        case .iban:
            return bankAccountIBAN
        }
    }
}
