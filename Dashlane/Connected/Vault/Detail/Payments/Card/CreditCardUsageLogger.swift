import Foundation
import DashlaneReportKit
import CorePersonalData

struct CreditCardUsageLogger {
    let usageLogService: UsageLogServiceProtocol

    func logCreditCardDetails(item: CreditCard, action: UsageLogCode68CreditcardDetails.ActionType) {
        let log = UsageLogCode68CreditcardDetails(action: action,
                                                  sender: .inApp,
                                                  identifier: item.anonId,
                                                  data2: item.expiryDate?.usageLogData ?? 3,
                                                  spaceId: item.spaceId)
        usageLogService.post(log)
    }
}

fileprivate extension Date {
    var usageLogData: Int {
        if self < Date() {
            return 0
        }

        if let daysDifference = Calendar.current.dateComponents([.day], from: Date(), to: self).day,
            daysDifference < 30*3 {
            return 1
        }

        if let daysDifference = Calendar.current.dateComponents([.day], from: Date(), to: self).day,
            daysDifference > 30*3 {
            return 2
        }

        return 3
    }
}
