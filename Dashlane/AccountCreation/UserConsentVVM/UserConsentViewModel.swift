import Foundation
import Combine
import DashTypes
import LoginKit
import SwiftTreats
import DesignSystem

protocol UserConsentViewModelProtocol {
    var legalNoticeEUAttributedString: AttributedString { get }
    var legalNoticeNonEUAttributedString: AttributedString { get }
}

class UserConsentViewModel: ObservableObject, UserConsentViewModelProtocol {

    @Published
    var email: String

    @Published
    var masterPassword: String

    @Published
    var hasUserAcceptedEmailMarketing: Bool

    @Published
    var hasUserAcceptedTermsAndConditions: Bool = false

    @Published
    var shouldDisplayMissingRequiredConsentAlert: Bool = false

    @Published
    var isAccountCreationRequestInProgress: Bool = false

    let isEmailMarketingOptInRequired: Bool

    let logger: AccountCreationInstallerLogger

    let completion: (Completion) -> Void

    enum Completion {
        case back(hasUserAcceptedTermsAndConditions: Bool, hasUserAcceptedEmailMarketing: Bool)
        case next(hasUserAcceptedTermsAndConditions: Bool, hasUserAcceptedEmailMarketing: Bool)
    }

    private let loginUsageLogService: LoginUsageLogServiceProtocol?

    init(email: DashTypes.Email,
         masterPassword: String,
         loginUsageLogService: LoginUsageLogServiceProtocol? = nil,
         isEmailMarketingOptInRequired: Bool,
         logger: AccountCreationInstallerLogger,
         completion: @escaping (Completion) -> Void) {
        self.email = email.address
        self.masterPassword = masterPassword
        self.isEmailMarketingOptInRequired = isEmailMarketingOptInRequired
        self.logger = logger
        self.loginUsageLogService = loginUsageLogService
        self.completion = completion

                self.hasUserAcceptedEmailMarketing = isEmailMarketingOptInRequired ? false : true
    }

        func back() {
        logger.log(.recap(action: .back))
        completion(.back(hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing))
    }

        func validate() {
                if skipValidationInDebug() { return }

        logger.log(.recap(action: .next))

                guard hasUserAcceptedTermsAndConditions else {
            shouldDisplayMissingRequiredConsentAlert = true
            logger.log(.recap(action: .termsAndConditionsAcceptanceMissing))
            return
        }

        logger.log(.recap(action: .termsAndConditionsAccepted))
        if hasUserAcceptedEmailMarketing {
            logger.log(.recap(action: .emailMarketingAccepted))
        } else {
            logger.log(.recap(action: .emailMarketingDeclined))
        }

        isAccountCreationRequestInProgress = true

        completion(.next(hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing))
    }

        private func skipValidationInDebug() -> Bool {
        #if DEBUG
        if !ProcessInfo.isTesting {
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
        let privacyString = L10n.Localizable.kwCreateAccountPrivacy
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

        let termString = L10n.Localizable.kwCreateAccountTermsConditions
        let privacyString = L10n.Localizable.kwCreateAccountPrivacy

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
