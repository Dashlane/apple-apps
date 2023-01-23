import Foundation

public enum BICVariant {
    case bic, routingNumber, sortcode
}

public enum IBANVariant {
    case iban, account, clabe
}

extension BankAccount {
    public var bicVariant: BICVariant {
        guard let code = self.country?.code else {
            return .bic
        }

        switch code {
        case "US":
            return .routingNumber
        case "GB":
            return .sortcode
        default:
            return .bic
        }
    }

    public var ibanVariant: IBANVariant {
        guard let code = self.country?.code else {
            return .iban
        }

        switch code {
        case "US", "GB":
            return .account
        case "MX":
            return .clabe
        default:
            return .iban
        }
    }
}
