import Foundation
import DashlaneReportKit

public struct LoginInstallerLogger {
    let installerLogService: InstallerLogServiceProtocol

    public init(installerLogService: InstallerLogServiceProtocol) {
        self.installerLogService = installerLogService
    }

    public func logShowLogin() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.1"))
    }

    public func logLoginBack() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.2"))
    }

    public func logEmailIsCorrect() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.4"))
    }

    public func logEmailIsIncorrect() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.5"))
        installerLogService.post(InstallerLogCode17Installer(step: "17.10"))
    }

    public func logUserNotFound() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.6"))
    }

    public func logShowToken() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.7"))
    }

    public func logShowResentAlert() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.7.1"))
    }

    public func logResentAlert() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.7.2"))
    }

    public func logCancelResendAlert() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.7.3"))
    }

    public func logTokenBack() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.8"))
        installerLogService.post(InstallerLogCode17Installer(step: "17.7"))
    }

    public func logBadToken() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.10"))
        installerLogService.post(InstallerLogCode17Installer(step: "17.5"))
    }

    public func logTokenOK() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.9"))
        installerLogService.post(InstallerLogCode17Installer(step: "17.6"))
    }

    public func logLockPassword() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.11"))
    }

    public func logLockPin() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.12"))
    }

    public func logLockTouchId() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.13"))
    }

    public func logLockBack() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.14"))
    }

    public func logMasterPasswordOk() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.15"))
    }

    public func logWrongMasterPassword() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.16"))
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.21.3"))
    }

    public func logPinCodeOk() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.17"))
    }

    public func logWrongPinCode() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.18"))
    }

    public func logTouchId(success: Bool) {
        if success {
            installerLogService.post(InstallerLogCode17Installer(step: "17.3.19"))
        } else {
            installerLogService.post(InstallerLogCode17Installer(step: "17.3.20"))
        }
    }

    public func logPasswordHelp() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.21"))
    }

    public func logCannotLogin() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.21.1"))
    }

    public func logForgotPassword() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.21.2"))
    }

    public func logTokenClick() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.4"))
    }

    public func logTokenTooManyAttempts() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.14"))
    }

    public func logOTPClick() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.33"))
    }

    public func logSSOSuccess() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.22"))
    }

    public func logSSOFailure() {
        installerLogService.post(InstallerLogCode17Installer(step: "17.3.23"))
    }
}
