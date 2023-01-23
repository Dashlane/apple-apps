import Foundation
import DashlaneReportKit

public protocol InstallerLogServiceProtocol {
    func post(_ log: InstallerLogCodeProtocol)

    var accountCreation: AccountCreationInstallerLogger { get }
    var login: LoginInstallerLogger { get }
    var app: AppInstallerLogger { get }
    var sso: SSOLoginInstallerLogger { get }
}


class FakeInstallerLogService: InstallerLogServiceProtocol {
    func post(_ log: InstallerLogCodeProtocol) {}
    var accountCreation: AccountCreationInstallerLogger { AccountCreationInstallerLogger(installerLogService: self) }
    var login: LoginInstallerLogger { LoginInstallerLogger(installerLogService: self) }
    var app: AppInstallerLogger { AppInstallerLogger(installerLogService: self, isFirstLaunch: false) }
    var sso: SSOLoginInstallerLogger { SSOLoginInstallerLogger(logService: self) }
}
