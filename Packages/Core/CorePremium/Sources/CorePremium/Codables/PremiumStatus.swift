import Foundation
import SwiftTreats

public struct PremiumStatus: Decodable {
    public struct BillingInformation: Decodable {
        public let type: String
        public let subtype: String?
        public let card_last4: String?
        public let card_type: String?
        public let card_exp_month: Int?
        public let card_exp_year: Int?
    }

    public struct FamilyInformation: Decodable {
        public let familyId: Int
        public let name: String
        public let isAdmin: Bool
    }

    public enum StatusCode: Int, Decodable {
        case free
        case premium
        case premiumRenewalStopped
        case legacy
        case freeTrial
        case grace
    }

    public enum PlanFeature: String, Codable, Defaultable {
        public static var defaultValue: PremiumStatus.PlanFeature = .none

        case sync
        case premiumPlus = "premiumplus"
        case advanced
        case essentials
        case none
    }

        public let statusCode: StatusCode

        public let success: Bool

        public let planName: String?

        public let planType: String?

        @Defaulted
    public var planFeature: PlanFeature

        public let endDate: Date?

        internal let previousPlan: PreviousPlanType?

        public let billingInformation: BillingInformation?

        public let currentTimestamp: Date?

        public let abtesting: ABTesting?

        public let autoRenewal: Bool?

        public let autoRenewalFailed: Bool?

        public let autoRenewInfo: AutoRenewInfo?

        public let hasInvoices: Bool?

        public let teamMembership: TeamMembership?

        public let familyMembership: [FamilyInformation]?

        public let recoveryHash: String?

        public let spaces: [Space]?

        public let capabilities: StatusCapabilitySet

    init(statusCode: PremiumStatus.StatusCode,
         success: Bool = true,
         planName: String? = nil,
         planType: String? = nil,
         planFeature: PlanFeature = .none,
         endDate: Date? = nil,
         previousPlan: PreviousPlanType? = nil,
         billingInformation: PremiumStatus.BillingInformation? = nil,
         currentTimestamp: Date? = nil,
         abtesting: ABTesting? = nil,
         autoRenewal: Bool? = nil,
         autoRenewalFailed: Bool? = nil,
         autoRenewInfo: AutoRenewInfo? = nil,
         hasInvoices: Bool? = nil,
         teamMembership: TeamMembership? = nil,
         familyMembership: [PremiumStatus.FamilyInformation]? = nil,
         recoveryHash: String? = nil,
         spaces: [Space]? = nil,
         capabilities: StatusCapabilitySet = .init()) {
        self.statusCode = statusCode
        self.success = success
        self.planName = planName
        self.planType = planType
        self._planFeature = .init(planFeature)
        self.endDate = endDate
        self.previousPlan = previousPlan
        self.billingInformation = billingInformation
        self.currentTimestamp = currentTimestamp
        self.abtesting = abtesting
        self.autoRenewal = autoRenewal
        self.autoRenewalFailed = autoRenewalFailed
        self.autoRenewInfo = autoRenewInfo
        self.hasInvoices = hasInvoices
        self.teamMembership = teamMembership
        self.familyMembership = familyMembership
        self.recoveryHash = recoveryHash
        self.spaces = spaces
        self.capabilities = capabilities
    }
}

extension PremiumStatus {
    public var actualPreviousPlan: PreviousPlan? {
        guard let previousPlan = previousPlan else {
            return nil
        }
        switch previousPlan {
        case .noPlan:
            return nil
        case .plan(let plan):
            return plan
        }
    }
}
