import Foundation
import CorePremium
import SecurityDashboard

extension PremiumService {
            var canShowIdentityProtection: Bool {
        let capability = self.capability(for: \.creditMonitoring)
        if capability.enabled {
            return true
        } else {
            return capability.info?.purchasable ?? false
        }
    }

        var isIdentityProtectionEnabled: Bool {
        return capability(for: \.creditMonitoring).enabled
    }

        var canShowIdentityTheftRestoration: Bool {
        return capability(for: \.identityRestoration).enabled
    }

}

extension PremiumService: PremiumInformation {
    private static let premiumCodes: [PremiumStatus.StatusCode] = [.premium, .premiumRenewalStopped, .legacy, .freeTrial]

    public var isPremium: Bool {
        guard let status = status else {
            return false
        }
        return Self.premiumCodes.contains(status.statusCode)
    }

    var isPremiumPlus: Bool {
        return isPremium && isIdentityProtectionEnabled
    }

    var canPurchasePremiumPlus: Bool {
        return canShowIdentityProtection
    }
}

extension PremiumService {
    var isDataLeakMonitoringAvailable: Bool {
        return capability(for: \.dataLeak).enabled
    }

    var areDarkWebAlertsHidden: Bool {
        guard let unavailabilityReason = capability(for: \.dataLeak).info?.reason else {
            return false
        }
        return unavailabilityReason == DarkWebMonitoringUnavailableReason.disabledFreeUser
    }
}
