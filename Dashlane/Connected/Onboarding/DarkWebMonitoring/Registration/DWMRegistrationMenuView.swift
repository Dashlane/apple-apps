import SwiftUI
import Combine
import UIDelight
import UIComponents
import DesignSystem

struct DWMRegistrationMenuView<Model: DWMRegistrationViewModelProtocol>: View {

    @ObservedObject
    var viewModel: Model

        enum Environment {
        case guidedOnboarding
        case onboardingChecklistItem
    }

    let environment: Environment

    @ViewBuilder
    var body: some View {
        VStack {
            if viewModel.shouldShowRegistrationRequestSent == false {
                checkForBreachesButton
            } else {
                VStack(alignment: .center, spacing: 16) {
                                        if viewModel.mailApps.isEmpty == false {
                        openEmailAppButton
                    }

                    confirmedEmailButton
                }
                .padding(.bottom, 48)
            }
        }
        .alert(isPresented: $viewModel.shouldDisplayError) {
            Alert(title: Text(viewModel.errorContent), dismissButton: .default(Text(L10n.Localizable.kwButtonOk), action: viewModel.errorDismissalCompletion))
        }
    }

    private var loadingAnimation: some View {
        let properties: [LottieView.DynamicAnimationProperty] = [
            .init(color: .white, keypath: "load.Ellipse 1.Stroke 1.Color"),
            .init(color: .white, keypath: "load 2.Ellipse 1.Stroke 1.Color")
        ]

        return LottieView(.loadingAnimationProgress, loopMode: .loop, dynamicAnimationProperties: properties)
            .frame(width: 20, height: 20)
    }

    private var checkForBreachesButton: some View {
        RoundedButton(L10n.Localizable.darkWebMonitoringOnboardingEmailViewCTA) {
            withAnimation {
                self.viewModel.register()
            }
        }
        .roundedButtonLayout(.fill)
        .roundedButtonDisplayProgressIndicator(viewModel.shouldShowLoading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 20)
        .padding(.bottom, 48)
    }

    private var openEmailAppButton: some View {
        RoundedButton(L10n.Localizable.darkWebMonitoringOnboardingEmailViewOpenEmailApp, action: {
            self.viewModel.openMailAppsMenu()
        })
        .roundedButtonLayout(.fill)
        .popSheet(isPresented: $viewModel.shouldShowMailAppsMenu, attachmentAnchor: .point(.top)) {
            PopSheet(title: Text(L10n.Localizable.darkWebMonitoringOnboardingEmailAppsTitle), message: nil, buttons: self.mailAppsActionSheetButtons())
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 20)
    }

    private var confirmedEmailButton: some View {
        Button(action: {
            self.viewModel.userIndicatedEmailWasConfirmed()
        }, label: {
            Text(L10n.Localizable.darkWebMonitoringOnboardingEmailViewConfirmedMyEmail)
        })
            .font(.headline)
            .padding(16)
            .foregroundColor(Color(asset: FiberAsset.guidedOnboardingSecondaryAction))
            .fixedSize(horizontal: false, vertical: true)
    }

    private func mailAppsActionSheetButtons() -> [PopSheet.Button] {
        let mailAppsButtons: [PopSheet.Button] = viewModel.mailApps.map { mailApp in
            switch mailApp {
            case .appleMail:
                return actionSheetButton(for: mailApp, withTitle: L10n.Localizable.darkWebMonitoringOnboardingEmailAppsAppleMail)
            case .gmail:
                return actionSheetButton(for: mailApp, withTitle: L10n.Localizable.darkWebMonitoringOnboardingEmailAppsGmail)
            case .outlook:
                return actionSheetButton(for: mailApp, withTitle: L10n.Localizable.darkWebMonitoringOnboardingEmailAppsOutlook)
            case .spark:
                return actionSheetButton(for: mailApp, withTitle: L10n.Localizable.darkWebMonitoringOnboardingEmailAppsSpark)
            case .yahooMail:
                return actionSheetButton(for: mailApp, withTitle: L10n.Localizable.darkWebMonitoringOnboardingEmailAppsYahooMail)
            }
        }

        let cancelButton: [PopSheet.Button] = [.cancel(Text(L10n.Localizable.darkWebMonitoringOnboardingEmailAppsCancel))]

        return mailAppsButtons + cancelButton
    }

    private func actionSheetButton(for emailApp: MailApp, withTitle title: String) -> PopSheet.Button {
        return .default(Text(title)) {
            self.viewModel.openMailApp(emailApp)
        }
    }
}

struct DWMEmailRegistrationMenu_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            DWMRegistrationMenuView(viewModel: FakeDWMEmailRegistrationInGuidedOnboardingViewModel(registrationRequestSent: false), environment: .guidedOnboarding)
            DWMRegistrationMenuView(viewModel: FakeDWMEmailRegistrationInGuidedOnboardingViewModel(registrationRequestSent: true), environment: .guidedOnboarding)
            DWMRegistrationMenuView(viewModel: FakeDWMEmailRegistrationInGuidedOnboardingViewModel(registrationRequestSent: false), environment: .onboardingChecklistItem)
            DWMRegistrationMenuView(viewModel: FakeDWMEmailRegistrationInGuidedOnboardingViewModel(registrationRequestSent: true), environment: .onboardingChecklistItem)
        }
    }
}
