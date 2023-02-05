import DashlaneReportKit
import CorePremium
import DashTypes
import SwiftTreats
import Foundation

public enum LogType {
    case info
    case warning
    case error
}

public enum LogPremiumType {
    case yearlyPlanDisplaySuccessful
    case yearlyPlanDisplayErrorFailToFetchData
    case yearlyReceiptFailedValidation
    case yearlyErrorOccurredForPurchase
    case yearlyChosen
    case yearlySuccessful
    case paywallDisplayedSecureNotes
    case paywallDisplayedDarkWebMonitoring
}

public protocol PremiumLogService {
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?)
}

private extension PremiumLogService {
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>? = nil) {
        self.post(log, completion: completion)
    }
}

public class PremiumStatusLogger {

    let premiumLogService: PremiumLogService

    public init(premiumLogService: PremiumLogService) {
        self.premiumLogService = premiumLogService
    }

    func logPurchase(_ plan: PurchasePlan.Kind, action: String, errorCode: String? = nil, origin: String?) {
        guard let currentPlanType = DashlanePremiumManager.shared.currentSession?.premiumStatus?.humanReadableActivePlan else {
            return
        }

        let log127 = UsageLogCode127CheckoutFlow(type: UsageLogCode127CheckoutFlow.TypeType.plansPage,
                                                 action: action,
                                                 action_sub: errorCode,
                                                 sender: origin ?? "",
                                                 path: "",
                                                 plan_screens_keys: "",
                                                 plan_id: plan.activePlan.logValue,
                                                 current_status: currentPlanType.logValue)
        premiumLogService.post(log127)
    }

    func logPremium(type: LogPremiumType) {
        var logCode: LogCodeProtocol

        switch type {
        case .yearlyPlanDisplaySuccessful:
            logCode = UsageLogCode35UserActionsMobile(type: "goPremium", action: "18")
        case .yearlyPlanDisplayErrorFailToFetchData:
            logCode = UsageLogCode35UserActionsMobile(type: "goPremium", action: "16")
        case .yearlyReceiptFailedValidation:
            logCode = UsageLogCode35UserActionsMobile(type: "goPremium", action: "19")
        case .yearlyErrorOccurredForPurchase:
            logCode = UsageLogCode35UserActionsMobile(type: "goPremium", action: "12")
        case .yearlyChosen:
            logCode = UsageLogCode35UserActionsMobile(type: "goPremium", action: "1")
        case .yearlySuccessful:
            logCode = UsageLogCode35UserActionsMobile(type: "goPremium", action: "5")
        case .paywallDisplayedSecureNotes:
            logCode = UsageLogCode75GeneralActions(type: "premium_prompt", subtype: "secure_notes", action: "display")
        case .paywallDisplayedDarkWebMonitoring:
            logCode = UsageLogCode75GeneralActions(type: "premium_prompt", subtype: "dark_web_monitoring", action: "display")
        }
        premiumLogService.post(logCode)
    }
}

fileprivate extension ActivePlan {
    var logValue: String {
        switch self {
        case .legacy:
            return "legacy"

        case .free:
            return "free"

        case .essentials:
            return "essentials"

        case .advanced:
            return "advanced"

        case .trial:
            return "freeTrial"

        case .premium:
            return "premium"

        case .premiumPlus:
            return "premiumPlus"

        case .premiumFamily:
            return "premiumFamily"

        case .premiumPlusFamily:
            return "premiumPlusFamily"
        }
    }
}

fileprivate extension PurchasePlan.Kind {
    var activePlan: ActivePlan {
        switch self {
        case .free:         return .free
        case .essentials:   return .essentials
        case .advanced:     return .advanced
        case .premium:      return .premium(.standard)
        case .family:       return .premiumFamily(isAdmin: true)
        }
    }
}
