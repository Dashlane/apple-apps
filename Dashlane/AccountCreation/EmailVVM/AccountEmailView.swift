import Foundation
import DashTypes
import CoreSession
import SwiftUI
import Combine
import UIDelight
import DashlaneAppKit
import SwiftTreats
import LoginKit
import UIComponents
import DesignSystem

struct AccountEmailView<Model: EmailViewModelProtocol>: View {
    @FocusState
    var isEmailFieldFocused: Bool

    @ObservedObject
    var model: Model

    private var emailIsValid: Bool {
        let login = Email(self.model.email)
        return login.isValid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            self.descriptionView
            self.emailField
            Spacer()
        }
        .reportPageAppearance(.accountCreationEmail)
        .loginAppearance()
        .navigationBarBackButtonHidden(true)
        .toolbar(content: { toolbarContent })
        .didAppear { 
            isEmailFieldFocused = true
            model.logger.log(.email(action: .shown))
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            NavigationBarButton(action: self.model.cancel, title: L10n.Localizable.minimalisticOnboardingEmailFirstBack)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationBarButton(action: self.validate) {
                Text(L10n.Localizable.minimalisticOnboardingEmailFirstNext)
                    .bold(self.emailIsValid)
                    .opacity(self.emailIsValid ? 1 : 0.5)
            }
            .disabled(self.model.shouldDisplayProgress)
        }
    }

    var descriptionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.Localizable.minimalisticOnboardingEmailFirstTitle)
                .font(DashlaneFont.custom(24, .medium).font)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 56)
                .padding(.horizontal, 24)
                .foregroundColor(.ds.text.neutral.catchy)

            Text(L10n.Localizable.minimalisticOnboardingEmailFirstSubtitle)
                .font(.body)
                .foregroundColor(.ds.text.neutral.standard)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
                .padding(.horizontal, 24)
        }

    }

    var emailField: some View {
        ZStack {
            LoginFieldBox {
                TextInput(L10n.Localizable.minimalisticOnboardingEmailFirstPlaceholder,
                          text: $model.email)
                .style(intensity: .supershy)
                .focused($isEmailFieldFocused)
                .onSubmit {
                    self.validate()
                }
                .disabled(model.shouldDisplayProgress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .bubbleErrorMessage(text: $model.bubbleErrorMessage)
                IndeterminateCircularProgress()
                    .frame(width: 20, height: 20)
                    .padding()
                    .hidden(!model.shouldDisplayProgress)
            }
            .alert(presenting: $model.currentAlert)
        }.padding(.top, 24)
    }

     private func emailUnavailableAlert() -> Alert {
        Alert(title: Text(L10n.Localizable.kwAccountCreationExistingAccount),
              primaryButton:
            .default(Text(L10n.Localizable.kwLoginNow), action: model.showLoginView),
              secondaryButton: .cancel(Text(L10n.Localizable.noAccountCreatedAlertAction)))
    }

    private func validate() {
        UIApplication.shared.endEditing()
        model.validate()
    }
}

extension AccountEmailView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        return .transparent(tintColor: .ds.text.neutral.standard, statusBarStyle: .default)
    }
}

struct EmailView_Previews: PreviewProvider {

    class FakeModel: EmailViewModelProtocol {
        var currentAlert: AlertContent?
        var bubbleErrorMessage: String?
        var shouldDisplayProgress = true
        var email: String = ""
        var confirmationEmail: String = ""
        var shouldDisplayBiometricAuthToggle: Bool = true
        var availableBiometryDisplayableName: String = "Face ID"
        var isBiometricAuthenticationEnabled: Bool = true
        var shouldDisplayBiometricAuthenticationInfoAlert: Bool = false
        var availableBiometry: Biometry? = .faceId
        var logger: AccountCreationInstallerLogger

        func validate() {}
        func validateFirstEmail() {}
        func cancel() {}
        func showLoginView() {}
        func showBiometricAuthenticationInfo() {
            shouldDisplayBiometricAuthenticationInfoAlert = true
        }

        init(logger: AccountCreationInstallerLogger) {
            self.logger = logger
        }
    }

    static let logger = AccountCreationInstallerLogger(installerLogService: InstallerLogService.mock)

    static var previews: some View {
        MultiContextPreview {
            AccountEmailView(model: FakeModel(logger: logger))
        }.accentColor(.ds.text.neutral.standard)
    }
}
