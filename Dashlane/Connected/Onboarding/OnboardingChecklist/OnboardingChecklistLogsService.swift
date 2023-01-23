import Foundation
import DashlaneReportKit

struct OnboardingChecklistLogsService {

    enum Dismissal: String {
        case allDone
        case timeOver
    }

    enum Event {
        case checklistDisplayed(actions: [OnboardingChecklistAction])
        case checklistActionSelected(action: OnboardingChecklistAction)
        case checklistDismissabilityUpdate(dismissability: OnboardingChecklistDismissability)
        case checklistDismissed(dismissal: Dismissal)

        var type: String {
            return "onboarding_checklist"
        }

        var subtype: String {
            switch self {
            case .checklistDisplayed(actions: let actions):
                return actions.formattedString()
            case .checklistActionSelected(action: let action):
                return action.rawValue
            case .checklistDismissabilityUpdate(dismissability: let dismissability):
                return dismissability.rawValue
            case .checklistDismissed(dismissal: let dismissal):
                return dismissal.rawValue
            }
        }

        var action: String {
            switch self {
            case .checklistDisplayed:
                return "display"
            case .checklistActionSelected:
                return "select"
            case .checklistDismissabilityUpdate:
                return "update"
            case .checklistDismissed:
                return "dismiss"
            }
        }
    }

    let usageLogService: UsageLogServiceProtocol

    func log(_ event: Event) {
        let log = UsageLogCode75GeneralActions(type: event.type,
                                               subtype: event.subtype,
                                               action: event.action)

        DispatchQueue.global(qos: .utility).async {
            self.usageLogService.post(log)
        }
    }
}

fileprivate extension Array where Element == OnboardingChecklistAction {
    func formattedString() -> String {
        let allActions = self.reduce(into: "") { result, action in
            if result.isEmpty {
                result = action.rawValue
            } else {
                result += "_" + action.rawValue
            }
        }

        if allActions.count >= 50 {
            assertionFailure("Characters limit is reached. The server can only accept the maximum of 50 characters for subtype.")
        }

        return allActions
    }
}
