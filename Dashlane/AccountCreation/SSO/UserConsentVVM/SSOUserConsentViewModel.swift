import Foundation

class SSOUserConsentViewModel: UserConsentViewModelProtocol, ObservableObject {
    let isEmailMarketingOptInRequired: Bool

    @Published
    var hasUserAcceptedEmailMarketing: Bool

    @Published
    var hasUserAcceptedTermsAndConditions: Bool = false

    @Published
    var shouldDisplayMissingRequiredConsentAlert: Bool = false

    @Published
    var isAccountCreationRequestInProgress = false

    let completion: (Completion) -> Void

    enum Completion {
        case finished(_ hasUserAcceptedTermsAndConditions: Bool, _ hasUserAcceptedEmailMarketing: Bool)
        case cancel
    }

    init(isEmailMarketingOptInRequired: Bool,
         completion: @escaping (Completion) -> Void) {
        self.isEmailMarketingOptInRequired = isEmailMarketingOptInRequired
        self.completion = completion

                self.hasUserAcceptedEmailMarketing = isEmailMarketingOptInRequired ? false : true
    }

    func signup() {
        guard hasUserAcceptedTermsAndConditions else {
            shouldDisplayMissingRequiredConsentAlert = true
            return
        }
        isAccountCreationRequestInProgress = true
        completion(.finished(hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing))
    }

    func cancel() {
        completion(.cancel)
    }
}
