import Foundation
import CorePremium
import DashlaneReportKit
import DashTypes

struct PremiumStatusUsageLogger {
    let usageLogService: UsageLogServiceProtocol

        func sendPremiumLogs(for premiumStatus: PremiumStatus) {
        let capabilities = premiumStatus.capabilities
        let docInfo = premiumStatus.capabilities.secureFiles.info
        let log = UsageLogCode53PremiumUser(planType: premiumStatus.planType,
                                            abtestingversion: premiumStatus.abtesting?.version,
                                            daysLeft: premiumStatus.daysLeft,
                                            isLegacy: premiumStatus.statusCode == .legacy,
                                            isPremium: premiumStatus.isPremiumUser,
                                            planName: premiumStatus.planName,
                                            status: premiumStatus.statusCode.rawValue,
                                            teamPlanStatus: premiumStatus.teamPlanStatus,
                                            AutoRenewalStatus: premiumStatus.autoRenewal,
                                            endDate: premiumStatus.endDate,
                                            storage_quota: docInfo?.quota.max,
                                            storage_used: docInfo?.quota.used,
                                            country: System.country,
                                            available_plans: premiumStatus.availableOffers.map { $0.planName }.joined(separator: ", "),
                                            credit_monitoring: capabilities.creditMonitoring.enabled,
                                            data_leak: capabilities.dataLeak.enabled,
                                            id_theft_protection: capabilities.identityTheftProtection.enabled,
                                            id_restoration: capabilities.identityRestoration.enabled,
                                            passwords_limit: capabilities.passwordsLimit.enabled,
                                            secure_wifi: capabilities.secureWiFi.enabled,
                                            security_breach: capabilities.securityBreach.enabled,
                                            sharing_limit: capabilities.sharingLimit.enabled,
                                            familyPlanStatus: premiumStatus.familyPlanStatus)
        usageLogService.post(log)
    }
}

fileprivate extension FileQuotaInfo.Quota {
    var used: Int {
        return max - remaining
    }
}

fileprivate extension PremiumStatus {
    var teamPlanStatus: UsageLogCode53PremiumUser.TeamPlanStatusType {
        guard let teamMembership = teamMembership else {
            return .noteam
        }
        return teamMembership.isBillingAdmin ? .admin : .member
    }

    var familyPlanStatus: UsageLogCode53PremiumUser.FamilyPlanStatusType {
        guard let familyMembership = familyMembership else {
            return .nofamily
        }

                assert(familyMembership.count < 2)

                guard let firstFamily = familyMembership.first else {
            return .nofamily
        }
        return firstFamily.isAdmin ? .admin : .member
    }

    var availableOffers: [Offer] {
        guard let offers = DashlanePremiumManager.shared.currentSession?.offers else {
            return []
        }

        return offers.allOffers
    }

    var daysLeft: Int? {
        guard let endDate = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: endDate).day
    }
}
