import Foundation
import DashlaneReportKit

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct AppInstallerLogger {
    let installerLogService: InstallerLogServiceProtocol
    let isFirstLaunch: Bool

    public init(installerLogService: InstallerLogServiceProtocol,
                isFirstLaunch: Bool) {
        self.installerLogService = installerLogService
        self.isFirstLaunch = isFirstLaunch
    }

    private func logUserInterface() {
        #if !os(macOS)
        let style = UITraitCollection.current.userInterfaceStyle
        switch style {
        case .dark:
            installerLogService.post(InstallerLogCode17Installer(step: "17.34.1", type: "darkThemeEnabled"))
        case .light:
            installerLogService.post(InstallerLogCode17Installer(step: "17.34.1", type: "lightThemeEnabled"))
        case .unspecified:
            installerLogService.post(InstallerLogCode17Installer(step: "17.34.1", type: "unspecifiedThemeEnabled"))
        @unknown default:
            assertionFailure("Unhandled interface style.")
            installerLogService.post(InstallerLogCode17Installer(step: "17.34.1", type: "unspecifiedThemeEnabled"))
        }
        #else
        switch NSApp.effectiveAppearance.name {
        case .darkAqua:
            installerLogService.post(InstallerLogCode17Installer(step: "17.34.1", type: "darkThemeEnabled"))
        case .aqua:
            installerLogService.post(InstallerLogCode17Installer(step: "17.34.1", type: "lightThemeEnabled"))
        default :
            installerLogService.post(InstallerLogCode17Installer(step: "17.34.1", type: "unspecifiedThemeEnabled"))
        }
        #endif
    }

    public func logAppLaunch() {
        if isFirstLaunch {
            installerLogService.post(InstallerLogCode17Installer(step: "17.9"))
        }
        installerLogService.post(InstallerLogCode17Installer(step: "17.34"))
        logUserInterface()
    }
}
