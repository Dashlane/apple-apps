import Foundation
import DashTypes
import DashlaneReportKit
import CoreNetworking
import CoreSession
import UIKit
import CoreFeature
import DashlaneAppKit
import LoginKit
import SwiftTreats

class InstallerLogService: InstallerLogServiceProtocol {
    func post(_ log: DashlaneReportKit.InstallerLogCodeProtocol) {
        tachyonLogger.logEngine.post(log)
    }

    var app: AppInstallerLogger {
        AppInstallerLogger(installerLogService: self, isFirstLaunch: appSettings.isFirstLaunch)
    }

    var login: LoginInstallerLogger {
        LoginInstallerLogger(installerLogService: self)
    }

    var accountCreation: AccountCreationInstallerLogger {
        AccountCreationInstallerLogger(installerLogService: self)
    }

    var sso: SSOLoginInstallerLogger {
        SSOLoginInstallerLogger(logService: self)
    }

    let tachyonLogger: TachyonLogger
    let appSettings: AppSettings

    init(appSettings: AppSettings, webService: LegacyWebService) {
        self.appSettings = appSettings
        let reportLogInfo = InstallerLogInfo(anonymouscomputerid: appSettings.anonymousDeviceId,
                                             version: DeviceHardware.name,
                                             os: System.platform,
                                             osversion: System.version,
                                             lang: System.language,
                                             country: System.country,
                                             platform: System.platform)
        let logEngine = LogEngine(reportLogInfo: reportLogInfo, uploadWebService: webService)
        tachyonLogger = TachyonLogger(engine: logEngine)
    }
}

extension InstallerLogService: ABTestingLogger {
    func log(_ test: ABTestProtocol) {
        let log = InstallerLogCode75ABTest(step: "75",
                                           experiment_id: type(of: test).technicalName,
                                           version_id: test.version,
                                           variant_id: test.rawVariant)
        tachyonLogger.logEngine.post(log)
    }
}



extension InstallerLogService {
    private struct FakeLogger: ABTestingLogger {
        func log(_ test: ABTestProtocol) {}
    }

    static var fakeAbTestLogger: ABTestingLogger { FakeLogger() }
}
