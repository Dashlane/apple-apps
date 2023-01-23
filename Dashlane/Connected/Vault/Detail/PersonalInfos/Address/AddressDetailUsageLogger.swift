import Foundation
import DashlaneReportKit
import CorePersonalData
import DashTypes

struct AddressDetailUsageLogger {
    let usageLogService: UsageLogServiceProtocol

        func logAddress(item: Address) {
        let log = UsageLogCode12PersonalDataClear(lang: System.language,
                                                  osformat: System.country,
                                                  oslang: System.language,
                                                  country: item.country?.code,
                                                  zipcode: item.zipCode)
        usageLogService.post(log)
    }
}
