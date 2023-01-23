import UIKit
import DashlaneReportKit
import DashTypes

final class HelpCenterSettingsViewModel: ObservableObject, SessionServicesInjecting {

    private enum Link: String {
        case howToGuide = "_"
        case troubleshooting = "_"
        case suggestFeature = "_"
        case privacyPolicy = "_"
        case termsOfService = "_"
        case deleteAccount = "_"
    }

    private enum Subaction: String {
        case getStarted
        case havingTrouble
        case feedback
        case deleteAccount
    }

    let usageLogService: UsageLogServiceProtocol

    init(usageLogService: UsageLogServiceProtocol) {
        self.usageLogService = usageLogService
    }

        func openHowToGuide() {
        logSupportAction(subaction: .getStarted)
        openLink(.howToGuide)
    }

    func openTroubleshooting() {
        logSupportAction(subaction: .havingTrouble)
        openLink(.troubleshooting)
    }

    func openDeleteAccount() {
        logSupportAction(subaction: .deleteAccount)
        openLink(.deleteAccount)
    }

    func suggestFeature() {
        logSupportAction(subaction: .feedback)
        openLink(.suggestFeature)
    }

    func openPrivacyPolicy() {
        openLink(.privacyPolicy)
    }

    func openTermsOfService() {
        openLink(.termsOfService)
    }

    private func openLink(_ link: Link) {
        guard let url = URL(string: link.rawValue) else { return }
        UIApplication.shared.open(url, options: [:])
    }

        private func logSupportAction(subaction: Subaction) {
        usageLogService.post(UsageLogCode75GeneralActions(type: "helpCenter", subtype: subaction.rawValue, action: "openSupport"))
    }
}

extension HelpCenterSettingsViewModel {
    static var mock: HelpCenterSettingsViewModel {
        .init(usageLogService: UsageLogService.fakeService)
    }
}
