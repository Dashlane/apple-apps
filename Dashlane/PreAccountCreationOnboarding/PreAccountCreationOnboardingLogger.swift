import Foundation
import DashlaneReportKit
import LoginKit

struct PreAccountCreationOnboardingLogger {

    let installerLogService: InstallerLogServiceProtocol

    enum Screen {
        case landingScreen
        case tutorialScreen(index: Int)

        var installLogId: String {
            switch self {
            case .landingScreen:
                return "17.91.1.0"
            case let .tutorialScreen(index):
                return "17.91.1.3.\(index)"
            }
        }

    }

    func displayed(screen: Screen) {
        installerLogService.post(InstallerLogCode17Installer(step: screen.installLogId))
    }
}
