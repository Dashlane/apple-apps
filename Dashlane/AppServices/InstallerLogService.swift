import Foundation
import DashlaneReportKit
import CoreNetworking
import CoreSession
import DashTypes
import AdSupport
import Network
import CoreTelephony
import AppTrackingTransparency
import DashlaneAppKit
import SwiftTreats
import LoginKit
import CoreUserTracking
import Adjust
import UIKit

class InstallerLogService: InstallerLogServiceProtocol {

    let networkReachability: NetworkReachability
    let appSettings: AppSettings
    let logger: Logger

    lazy var logEngine: LogEngine = {
        let reportLogInfo = InstallerLogInfo(anonymouscomputerid: appSettings.anonymousDeviceId,
                                             version: Application.version(),
                                             os: System.platform,
                                             osversion: System.version,
                                             lang: System.language,
                                             country: System.country,
                                             platform: System.platform)

        return LogEngine(reportLogInfo: reportLogInfo, uploadWebService: LegacyWebServiceImpl(), localLogger: logger, journalPath: nil)
    }()

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

    init(logger: Logger,
         appSettings: AppSettings,
         networkReachability: NetworkReachability) {
        self.appSettings = appSettings
        self.logger = logger
        self.networkReachability = networkReachability
    }

    func post(_ log: InstallerLogCodeProtocol) {
        logEngine.post(log)
    }

    func trackInstall() {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        let doNotTrack = ATTrackingManager.trackingAuthorizationStatus != .authorized
        var isDebug = false
        #if targetEnvironment(macCatalyst)
        let carrierName: String? = nil
        #else
        let carrierName = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value.carrierName
        #endif

        #if DEBUG
        if !ProcessInfo.isTesting {
            isDebug = true
        }
        #endif

        logEngine.trackInstall(isDebug: isDebug,
                               origin: "iOS",
                               osVersion: System.version,
                               idfa: idfa,
                               idfv: idfv,
                               interfaceType: networkReachability.interfaceType,
                               carrierName: carrierName,
                               platform: Device.hardwareName,
                               osCountry: System.country,
                               doNotTrack: doNotTrack,
                               anonymousDeviceId: appSettings.anonymousDeviceId) { _ in }
    }
}

extension InstallerLogService {
    private class FakeInstallerLogService: InstallerLogServiceProtocol {
        func post(_ log: InstallerLogCodeProtocol) {}
        var accountCreation: AccountCreationInstallerLogger { AccountCreationInstallerLogger(installerLogService: self) }
        var login: LoginInstallerLogger { LoginInstallerLogger(installerLogService: self) }
        var app: AppInstallerLogger { AppInstallerLogger(installerLogService: self, isFirstLaunch: false) }
        var sso: SSOLoginInstallerLogger { SSOLoginInstallerLogger(logService: self) }
    }

    static var mock: InstallerLogServiceProtocol {
        return FakeInstallerLogService()
    }
}

extension UserTrackingAppActivityReporter {
    func trackInstall() {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        let isMarketingOptIn = ATTrackingManager.trackingAuthorizationStatus == .authorized

        let event = UserEvent.FirstLaunch(ios: Definition.Ios(
            adid: Adjust.adid(),
            idfa: idfa,
            idfv: idfv),
                                          isMarketingOptIn: isMarketingOptIn)
        report(event)
    }
}
