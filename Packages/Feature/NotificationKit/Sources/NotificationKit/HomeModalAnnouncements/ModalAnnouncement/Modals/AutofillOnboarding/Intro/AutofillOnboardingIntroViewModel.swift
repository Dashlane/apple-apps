import Foundation
import CoreUserTracking

@MainActor
public struct AutofillOnboardingIntroViewModel: HomeAnnouncementsServicesInjecting {
    let shouldShowSync: Bool
    let activityReporter: ActivityReporterProtocol
    let action: @MainActor () -> Void
    let dismiss: @MainActor () -> Void

    public init(shouldShowSync: Bool,
                activityReporter: ActivityReporterProtocol,
                action: @MainActor @escaping () -> Void,
                dismiss: @MainActor @escaping () -> Void) {
        self.shouldShowSync = shouldShowSync
        self.activityReporter = activityReporter
        self.action = action
        self.dismiss = dismiss
    }

    func report(page: AutofillOnboardingIntroView.AutofillTutorialPage) {
        switch page {
        case .login: activityReporter.reportPageShown(Page.autofillTutorialHowToLogin)
        case .generatePasswords: activityReporter.reportPageShown(Page.autofillTutorialHowToGeneratePasswords)
        case .sync: activityReporter.reportPageShown(Page.autofillTutorialHowToSyncInformation)
        }
    }
}

extension AutofillOnboardingIntroViewModel {
    static var mock: AutofillOnboardingIntroViewModel {
        .init(shouldShowSync: true,
              activityReporter: .fake,
              action: {},
              dismiss: {})
    }
}
