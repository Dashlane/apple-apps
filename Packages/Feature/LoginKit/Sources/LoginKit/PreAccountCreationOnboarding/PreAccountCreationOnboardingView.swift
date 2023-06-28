#if canImport(UIKit)

import SwiftUI
import UIComponents
import UIDelight
import DesignSystem
import CoreLocalization
import CoreKeychain
import DashTypes
import SwiftTreats

public struct PreAccountCreationOnboardingView: View {
    private var model: PreAccountCreationOnboardingViewModel
    @State
    private var alertContent: AlertContent?

    public init(model: PreAccountCreationOnboardingViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack {
            TabView {
                Group {
                    PreAccountCreationOnboardingPage(step: .authenticator)
                        .hidden(!model.hasAuthenticator)
                    PreAccountCreationOnboardingPage(step: .trust)
                    PreAccountCreationOnboardingPage(step: .vault)
                    PreAccountCreationOnboardingPage(step: .autofill)
                    PreAccountCreationOnboardingPage(step: .privacy)
                    PreAccountCreationOnboardingPage(step: .security)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.bottom, 40)
            }
            .frame(maxHeight: .infinity)
            .tabViewStyle(PageTabViewStyle())

            VStack(spacing: 8) {
                DS.Button(L10n.Core.onboardingV3CTACreateAccount, action: model.showAccountCreation)
                DS.Button(L10n.Core.onboardingV3CTALogIn, action: model.showLogin)
                    .style(intensity: .supershy)
            }
            .roundedButtonLayout(.fill)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .overlay(alignment: .topTrailing) {
            DS.Button(icon: .ds.feedback.info.outlined) {
                alertContent = analyticsAlert
            }
            .style(mood: .brand, intensity: .supershy)
            .controlSize(.small)
            .padding()
            .hidden(BuildEnvironment.current == .appstore)
        }
        .loginAppearance()
        .alert(presenting: $alertContent)
        .onAppear {
            guard PreAccountCreationOnboardingViewModel.shouldDeleteLocalData else { return }
            alertContent = localDeletionAlert
        }
        .navigationBarTitleDisplayMode(.inline)
        .reportPageAppearance(.onboardingTrustScreens)
    }

        var analyticsAlert: AlertContent {
        AlertContent(
            title: "Analytics Installation Id",
            message: model.analyticsInstallationId.uuidString,
            buttons: .two(
                primaryButton: .init(title: "Copy", action: {
                    UIPasteboard.general.string = model.analyticsInstallationId.uuidString
                }),
                secondaryButton: .init(title: "Cancel", action: {})
            )
        )
    }

    var localDeletionAlert: AlertContent {
        AlertContent(
            title: L10n.Core.deleteLocalDataAlertTitle,
            message: L10n.Core.deleteLocalDataAlertMessage,
            buttons: .two(
                primaryButton: .init(
                    title: L10n.Core.deleteLocalDataAlertDeleteCta,
                    action: model.deleteAllLocalData
                ),
                secondaryButton: .init(
                    title: L10n.Core.cancel,
                    action: model.disableShouldDeleteLocalData
                )
            )
        )
    }
}

struct PreAccountCreationOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
                PreAccountCreationOnboardingView(model: .init(
            keychainService: .fake,
            logger: LoggerMock(),
            completion: { _ in }
        ))
    }
}

#endif
