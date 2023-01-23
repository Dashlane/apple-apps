import Foundation

public extension PremiumStatus {
        var isBusinessAccount: Bool {
        return (self.spaces?.count ?? 0) > 0
    }

    var isFamilyInvitee: Bool {
        if let familyInformation = familyMembership?.first {
            return !familyInformation.isAdmin
        }
        return false
    }
    
        var isPremiumFreeOfCharge: Bool {
                guard statusCode == .premium,
              !capabilities.secureWiFi.enabled,
              let reason = capabilities.secureWiFi.info?.reason  else {
            return false
        }

        return reason == .payment
    }

        func isPremiumFreeForLife() -> Bool {
        guard statusCode == .premium, let years = yearsToExpiration()  else {
            return false
        }

                        return years > 65
    }

    func daysToExpiration() -> Int? {
        guard let endDate = endDate else {
            return nil
        }

        return Calendar.current.dateComponents([.day], toStartOfTheDayOf: endDate).day
    }

    private func yearsToExpiration() -> Int? {
        guard let endDate = endDate else {
            return nil
        }

        return Calendar.current.dateComponents([.year], toStartOfTheDayOf: endDate).year
    }
}

extension Calendar {
    func dateComponents(_ components: Set<Calendar.Component>, toStartOfTheDayOf end: Date) -> DateComponents {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let endDateUpdated = calendar.startOfDay(for: end)
        return calendar.dateComponents(components, from: today, to: endDateUpdated)
    }
}
