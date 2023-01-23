import Foundation
import DashlaneReportKit
import CorePersonalData
import DashTypes

struct IdentityDetailUsageLogger {
    let usageLogService: UsageLogServiceProtocol

        func logIdentity(item: Identity) {

        let gender = item.gender.flatMap {
            UsageLogCode12PersonalDataClear.GenderType.init(rawValue: $0.rawValue)
        }
        let log = UsageLogCode12PersonalDataClear(birth: item.$birthDate?.year,
                                                  format: System.country,
                                                  gender: gender,
                                                  lang: System.language,
                                                  osformat: System.country,
                                                  oslang: System.language)
        usageLogService.post(log)
    }

}
