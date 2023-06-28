import Foundation
import Combine
import DashTypes

public class AutofillBannerViewModel: ObservableObject {

    public enum Action {
        case showAutofillDemo
    }

    private let action: (Action) -> Void

    public init(action: @escaping (Action) -> Void) {
        self.action = action
    }

    func showAutofillDemo() {
        action(.showAutofillDemo)
    }

}

public extension AutofillBannerViewModel {
    static var mock: AutofillBannerViewModel {
        AutofillBannerViewModel(action: { _ in })
    }
}
