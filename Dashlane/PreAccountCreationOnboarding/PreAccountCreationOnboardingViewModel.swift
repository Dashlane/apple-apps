import Foundation
import DashlaneReportKit
import CoreUserTracking
import CoreSession
import CoreSettings
import DashTypes
import LoginKit

class PreAccountCreationOnboardingViewModel: SessionServicesInjecting {
    enum NextStep {
        case accountCreation
        case login
    }

    let installerLogService: InstallerLogServiceProtocol
    let logger: PreAccountCreationOnboardingLogger
    let analyticsInstallationId: LowercasedUUID
    private let localDataRemover: LocalDataRemover

    init(installerLogService: InstallerLogServiceProtocol,
         localDataRemover: LocalDataRemover) {
        self.installerLogService = installerLogService
        self.logger = .init(installerLogService: installerLogService)
        self.analyticsInstallationId = UserTrackingAppActivityReporter.analyticsInstallationId
        self.localDataRemover = localDataRemover
    }

    var completion: ((NextStep) -> Void)?

    func showLogin() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.1"))
        installerLogService.post(InstallerLogCode17Installer(step: "17.91.1.1"))
        completion?(.login)
    }

    func showAccountCreation() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3"))
        installerLogService.post(InstallerLogCode17Installer(step: "17.91.1.2"))
        completion?(.accountCreation)
    }

        func disableShouldDeleteLocalDataSetting() {
        localDataRemover.disableShouldDeleteLocalData()
    }

    func deleteAllLocalData() {
        localDataRemover.removeContainerData()
    }
}
