import Foundation
import CoreFeature
import DashlaneReportKit
import LoginKit

struct ABTestingUsageLogger: ABTestingLogger {

    let usageLogService: UsageLogServiceProtocol

    func log(_ test: ABTestProtocol) {
        let log = UsageLogCode132ABTest(experiment_id: type(of: test).technicalName,
                                        version_id: test.version,
                                        variant_id: test.rawVariant)
        usageLogService.post(log)
    }
}

struct ABTestingInstallerLogger: ABTestingLogger {

    let installerLogService: InstallerLogServiceProtocol

    func log(_ test: ABTestProtocol) {
        let log = InstallerLogCode75ABTest(step: "75",
                                           experiment_id: type(of: test).technicalName,
                                           version_id: test.version,
                                           variant_id: test.rawVariant)
        installerLogService.post(log)
    }
}

extension InstallerLogService {
    var abTesting: ABTestingInstallerLogger {
        ABTestingInstallerLogger(installerLogService: self)
    }
}

extension UsageLogServiceProtocol {
    var abTesting: ABTestingUsageLogger {
        ABTestingUsageLogger(usageLogService: self)
    }
}
