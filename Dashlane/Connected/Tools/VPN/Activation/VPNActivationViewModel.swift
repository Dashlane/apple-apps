import UIKit
import DashTypes
import Combine
import CoreUserTracking
import DashlaneAppKit
import DesignSystem
import CoreSession
import CoreLocalization

public enum VPNActivationState {
    case initial
    case loading
    case success
    case error(Error)
}

final class VPNActivationViewModel: ObservableObject, SessionServicesInjecting {

    @Published var email = ""
    @Published var hasUserAcceptedTermsAndConditions = false
    @Published var termsTextViewHeight: CGFloat? = 50
    @Published var activationState: VPNActivationState
    @Published var isEmailAddressValid = true

    var legalNoticeAttributedString: AttributedString {
        AttributedString.buildVPNLegalNoticeAttributedString()
    }

    internal let vpnService: VPNServiceProtocol
    internal let activityReporter: ActivityReporterProtocol
    internal var actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>

    required init(vpnService: VPNServiceProtocol,
                  activityReporter: ActivityReporterProtocol,
                  session: Session,
                  actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>,
                  activationState: VPNActivationState = .initial) {
        self.vpnService = vpnService
        self.activityReporter = activityReporter
        self.actionPublisher = actionPublisher
        self.activationState = activationState
        self.email = session.login.email
    }

    func activateEmail() {
        isEmailAddressValid = Email(email).isValid

        guard isEmailAddressValid && hasUserAcceptedTermsAndConditions else { return }

        logActivationStart()
        activationState = .loading
        vpnService.activateEmail(email) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.activationState = .error(error)
                self.logActionError(for: error)
            case .success:
                self.activationState = .success

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.actionPublisher.send(.accountActivated)
                }
            }
        }
    }

    var errorTitle: String? {
        guard case .error(let error) = activationState,
              case VPNServiceError.userAlreadyHasAnAccountForProvider = error
        else {
            return nil
        }
        return L10n.Localizable.vpnActivationViewErrorAlreadyUsedEmailTitle
    }

    var errorDescription: String? {
        guard case .error(let error) = activationState,
              case VPNServiceError.userAlreadyHasAnAccountForProvider = error
        else {
            return nil
        }
        return L10n.Localizable.vpnActivationViewErrorAlreadyUsedEmailDescription
    }

    func contactSupport() {
        guard case .error(let error) = activationState,
              case VPNServiceError.userAlreadyHasAnAccountForProvider = error
        else {
            actionPublisher.send(.openVPNUsageSupport)
            return
        }
        actionPublisher.send(.openHotspotShieldSupport)
    }

    func learnMoreAboutVPN() {
        actionPublisher.send(.openVPNUsageSupport)

    }
    func logActivationStart() {
        activityReporter.report(UserEvent.ActivateVpn(flowStep: .start))
    }

    private func logActionError(for error: Error) {
        switch error {
        case VPNServiceError.userAlreadyHasAnAccountForProvider:
            activityReporter.report(UserEvent.ActivateVpn(errorName: .emailAlreadyInUse, flowStep: .error))
        case is VPNServiceError:
            break
        default:
            activityReporter.report(UserEvent.ActivateVpn(errorName: .serverError, flowStep: .error))
        }
    }

    public static func mock(activationState: VPNActivationState = .initial) -> VPNActivationViewModel {
        return VPNActivationViewModel(vpnService: VPNServiceMock(),
                                      activityReporter: .fake,
                                      session: .mock,
                                      actionPublisher: .init(),
                                      activationState: activationState)
    }
}

private extension AttributedString {

    private static func linkAttributes(for url: URL) -> AttributeContainer {
        var attributeContainer = AttributeContainer()
        attributeContainer.link = url
        attributeContainer.underlineStyle = .single
        attributeContainer.font = .system(.footnote)
        attributeContainer.foregroundColor = .ds.text.brand.standard
        return attributeContainer
    }

    static func buildVPNLegalNoticeAttributedString() -> AttributedString {
        let termsURL = URL(string: "_")!
        let privacyPolicyURL = URL(string: "_")!

        let termString = L10n.Localizable.vpnActivationViewTermsOfService
        let privacyString = CoreLocalization.L10n.Core.kwCreateAccountPrivacy

        let legalNotice = L10n.Localizable.vpnActivationViewTermsAgree(termString, privacyString)

        var attributedString = AttributedString(legalNotice)
        attributedString.font = .system(.footnote)
        attributedString.foregroundColor = .ds.text.neutral.standard

        for (text, url) in [termString: termsURL, privacyString: privacyPolicyURL] {
            guard let range = attributedString.range(of: text) else { continue }
            attributedString[range].setAttributes(linkAttributes(for: url))
        }

        return attributedString
    }
}
