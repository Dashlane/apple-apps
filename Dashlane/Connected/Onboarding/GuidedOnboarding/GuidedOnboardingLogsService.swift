import Foundation
import DashlaneReportKit

struct GuidedOnboardingLogsService {

    enum Event {
        case displayed(question: GuidedOnboardingQuestion)
        case selected(answer: GuidedOnboardingAnswer)
        case continueAfterSelectingAnswer(answer: GuidedOnboardingAnswer, question: GuidedOnboardingQuestion)
        case faqSectionDisplayed
        case faqItemSelected(item: OnboardingFAQ)
        case guidedOnboardingSkipped
        case planScreenShown
        case planScreenDismissed

        var subtype: String {
            let faq = "faq"
            let skip = "skip"
            let planScreen = "planScreen"

            switch self {
            case .displayed(question: let question):
                return question.stringValue
            case .selected(answer: let answer):
                return answer.stringValue
            case .continueAfterSelectingAnswer(answer: let answer, question: let question):
                return combine(question.stringValue, answer.stringValue)
            case .faqSectionDisplayed:
                return faq
            case .faqItemSelected(item: let item):
                return combine(faq, item.stringValue)
            case .guidedOnboardingSkipped:
                return skip
            case .planScreenShown:
                return planScreen
            case .planScreenDismissed:
                return planScreen
            }
        }

        var action: String {
            let tap = "tap"
            let display = "display"
            let dismiss = "dismiss"

            switch self {
            case .displayed:
                return display
            case .selected:
                return tap
            case .continueAfterSelectingAnswer:
                return tap
            case .faqSectionDisplayed:
                return display
            case .faqItemSelected:
                return tap
            case .guidedOnboardingSkipped:
                return tap
            case .planScreenShown:
                return display
            case .planScreenDismissed:
                return dismiss
            }
        }

        var subaction: String? {
            switch self {
            case .continueAfterSelectingAnswer:
                return "continue"
            case .displayed, .selected, .faqSectionDisplayed, .faqItemSelected, .guidedOnboardingSkipped, .planScreenShown, .planScreenDismissed:
                return nil
            }
        }

        private func combine(_ value1: String, _ value2: String) -> String {
            return value1 + "_" + value2
        }
    }

    let usageLogService: UsageLogServiceProtocol

    func log(_ event: Event) {
        let log = UsageLogCode75GeneralActions(type: "guided_onboarding",
                                               subtype: event.subtype,
                                               action: event.action,
                                               subaction: event.subaction)

        DispatchQueue.global(qos: .utility).async {
            self.usageLogService.post(log)
        }
    }
}

fileprivate extension GuidedOnboardingQuestion {
    var stringValue: String {
        switch self {
        case .whyDashlane:
            return "whyDashlane"
        case .howPasswordsHandled:
            return "howPasswordsHandled"
        }
    }
}

fileprivate extension GuidedOnboardingAnswer {
    var stringValue: String {
        switch self {
        case .autofill:
            return "autofill"
        case .storeAccountsSecurely:
            return "storeAccountsSecurely"
        case .protectMyAccounts:
            return "protectMyAccounts"
        case .memorizePasswords:
            return "memorizePasswords"
        case .browser:
            return "browser"
        case .anotherPasswordManager:
            return "anotherPasswordManager"
        case .somethingElse:
            return "somethingElse"
        case .syncAcrossDevices:
            return "syncAcrossDevices"
        case .warnMeAboutHacks:
            return "warnMeAboutHacks"
        }
    }
}

fileprivate extension OnboardingFAQ {
    var stringValue: String {
        switch self {
        case .whatIfDashlaneGetsHacked:
            return "whatIfDashlaneGetsHacked"
        case .canDashlaneSeeMyPassword:
            return "canDashlaneSeeMyPassword"
        case .howDoesDashlaneMakeMoney:
            return "howDoesDashlaneMakeMoney"
        case .canILeaveAndTakeMyData:
            return "canILeaveAndTakeMyData"
        case .isDashlaneReallyMoreSecure:
            return "isDashlaneReallyMoreSecure"
        }
    }
}

extension UsageLogServiceProtocol {
    var guidedOnboardingLogsService: GuidedOnboardingLogsService {
        return GuidedOnboardingLogsService(usageLogService: self)
    }
}
