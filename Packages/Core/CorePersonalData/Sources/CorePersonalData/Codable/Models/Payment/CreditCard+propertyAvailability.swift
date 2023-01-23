import Foundation

extension CreditCard {
    public func isPropertyAvailable<T>(for keypath: KeyPath<CreditCard, T>) -> Bool {
        guard let code = self.country?.code else {
            return true
        }

        switch keypath {
        case \CreditCard.issueNumber,
             \CreditCard.startYear,
             \CreditCard.startMonth,
             \CreditCard.issuingDate:

            return ["GB", "MX", "JP", "CN", "KR", "IN", "BR", "AR", "CL", "CO", "PE", "NO", "PT", "SE"].contains(code)

        default:
            return true
        }
    }
}
