import Foundation
import Combine
import DashTypes
import LoginKit
import SwiftTreats
import DesignSystem
import CoreLocalization

protocol UserConsentViewModelProtocol {
    var legalNoticeEUAttributedString: AttributedString { get }
    var legalNoticeNonEUAttributedString: AttributedString { get }
}

class UserConsentViewModel: ObservableObject, UserConsentViewModelProtocol, AccountCreationFlowDependenciesInjecting {
    @Published
    var hasUserAcceptedEmailMarketing: Bool

    @Published
    var hasUserAcceptedTermsAndConditions: Bool = false

    @Published
    var shouldDisplayMissingRequiredConsentAlert: Bool = false

    @Published
    var isAccountCreationRequestInProgress: Bool = false

    let isEmailMarketingOptInRequired: Bool

    let completion: (Completion) -> Void

    enum Completion {
        case back(hasUserAcceptedTermsAndConditions: Bool, hasUserAcceptedEmailMarketing: Bool)
        case next(hasUserAcceptedTermsAndConditions: Bool, hasUserAcceptedEmailMarketing: Bool)
    }

    init(isEmailMarketingOptInRequired: Bool,
         completion: @escaping (UserConsentViewModel.Completion) -> Void) {
        self.isEmailMarketingOptInRequired = isEmailMarketingOptInRequired
        self.completion = completion

                self.hasUserAcceptedEmailMarketing = isEmailMarketingOptInRequired ? false : true
    }

        func back() {
        completion(.back(hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing))
    }

        func validate() {
                if skipValidationInDebug() { return }

                guard hasUserAcceptedTermsAndConditions else {
            shouldDisplayMissingRequiredConsentAlert = true
            return
        }

        isAccountCreationRequestInProgress = true

        completion(.next(hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing))
    }

        private func skipValidationInDebug() -> Bool {
        #if DEBUG
        if !ProcessInfo.isTesting {
            isAccountCreationRequestInProgress = true
            hasUserAcceptedEmailMarketing = true
            hasUserAcceptedTermsAndConditions = true
            completion(.next(hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing))
            return true
        }
        #endif
        return false
    }
}

extension UserConsentViewModelProtocol {

    private static func linkAttributes(for url: URL) -> AttributeContainer {
        var attributeContainer = AttributeContainer()
        attributeContainer.link = url
        attributeContainer.underlineStyle = .single
        attributeContainer.foregroundColor = .ds.text.brand.standard
        return attributeContainer
    }

    var legalNoticeEUAttributedString: AttributedString {
        let termsURL = URL(string: "_")!
        let privacyPolicyURL = URL(string: "_")!

        let termString = L10n.Localizable.createaccountPrivacysettingsTermsConditions
        let privacyString = CoreLocalization.L10n.Core.kwCreateAccountPrivacy
        let requiredString = L10n.Localizable.createaccountPrivacysettingsRequiredLabel

        let legalNotice = L10n.Localizable.minimalisticOnboardingRecapCheckboxTerms(termString, privacyString, requiredString)

        var attributedString = AttributedString(legalNotice)
        attributedString.foregroundColor = .ds.text.neutral.standard
        attributedString.font = .system(.body)

        for (text, url) in [termString: termsURL, privacyString: privacyPolicyURL] {
            guard let range = attributedString.range(of: text) else { continue }
            attributedString[range].setAttributes(Self.linkAttributes(for: url))
        }

        return attributedString
    }

    var legalNoticeNonEUAttributedString: AttributedString {
        let termsURL = URL(string: "_")!
        let privacyPolicyURL = URL(string: "_")!

        let termString = CoreLocalization.L10n.Core.kwCreateAccountTermsConditions
        let privacyString = CoreLocalization.L10n.Core.kwCreateAccountPrivacy

        let legalNotice = L10n.Localizable.kwCreateAccountTermsConditionsPrivacyNotice(termString, privacyString)

        var attributedString = AttributedString(legalNotice)
        attributedString.font = .system(.footnote)
        attributedString.foregroundColor = .ds.text.neutral.standard

        for (text, url) in [termString: termsURL, privacyString: privacyPolicyURL] {
            guard let range = attributedString.range(of: text) else { continue }
            attributedString[range].setAttributes(Self.linkAttributes(for: url))
        }

        return attributedString
    }
}
