import Foundation
import SwiftUI
import Combine
import CorePasswords
import DashTypes
import UIDelight
import LoginKit
import UIComponents
import DesignSystem
import CoreKeychain

struct NewMasterPasswordView: View {

    @ObservedObject
    var model: NewMasterPasswordViewModel

    @State private var showPasswordTips: Bool = false

    let title: String

    @FocusState private var creationMasterPasswordFocused: Bool
    @FocusState private var confirmationMasterPasswordFocused: Bool

    var backButtonTitle: String {
        switch model.step {
        case .masterPasswordCreation:
            return L10n.Localizable.minimalisticOnboardingMasterPasswordSecondBack
        case .masterPasswordConfirmation:
            return L10n.Localizable.minimalisticOnboardingMasterPasswordSecondConfirmationBack
        }
    }

    var nextButtonLabel: some View {
        switch model.step {
        case .masterPasswordCreation:
            return Text(L10n.Localizable.minimalisticOnboardingMasterPasswordSecondNext)
                .bold(model.canCreate == true)
                .opacity(model.canCreate ? 1 : 0.5)
        case .masterPasswordConfirmation:
            return Text(L10n.Localizable.minimalisticOnboardingMasterPasswordSecondConfirmationNext).bold(model.password == model.confirmationPassword && model.canCreate == true)
                                .opacity(1)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            description
            textFields
            helperViews
            Spacer()
        }
        .reportPageAppearance(.accountCreationCreateMasterPassword)
        .onReceive(model.stepOnFocusPublisher, perform: focusTextField(for:))
        .loginAppearance()
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(label: backButtonTitle, action: didTapBackButton)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(action: didTapNextButton) {
                    nextButtonLabel
                }
            }
        }
        .didAppear { 
            self.model.focusActivated = true
            self.model.logger?.log(.masterPasswordInitialEntry(action: .shown))
        }
    }

    private func focusTextField(for step: NewMasterPasswordViewModel.Step) {
        switch step {
        case .masterPasswordCreation:
            creationMasterPasswordFocused = true
        case .masterPasswordConfirmation:
            confirmationMasterPasswordFocused = true
        }
    }

    private var helperViews: some View {
        VStack(alignment: .leading, spacing: 16) {
            if model.step == .masterPasswordCreation {
                passwordStrengthView
                inputFeedbackLabel
            }

            if model.step == .masterPasswordConfirmation {
                if model.canCreate {
                    inputFeedbackLabel
                } else {
                    passwordStrengthView
                }
            }
        }
    }

    private var description: some View {
        VStack(alignment: .leading, spacing: 8) {
            if model.step == .masterPasswordCreation {
                switch model.mode {
                case .accountCreation:
                    styledTitle(L10n.Localizable.minimalisticOnboardingMasterPasswordSecondTitle)
                case .masterPasswordChange:
                    styledTitle(L10n.Localizable.mpchangeNewMasterPassword)
                }

                Button(action: {
                    self.showPasswordTips = true
                }, label: {
                    needHelpLabel
                }).sheet(isPresented: $showPasswordTips, content: {
                    PasswordTipsView { result in
                        switch result {
                        case .shown:
                            self.model.logger?.log(.masterPasswordInitialEntry(action: .tipsShown))
                        }
                    }
                })
                    .padding(.top, 8)
            } else {
                styledTitle(L10n.Localizable.minimalisticOnboardingMasterPasswordConfirmationTitle)
                styledSubtitle(L10n.Localizable.minimalisticOnboardingMasterPasswordConfirmationSubtitle)
            }
        }
        .padding(.top, 56)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private var initialEntryField: some View {
        LoginFieldBox {
            TextInput(L10n.Localizable.minimalisticOnboardingMasterPasswordSecondPlaceholder,
                      text: $model.password)
            .textInputIsSecure(true)
            .focused($creationMasterPasswordFocused)
            .onSubmit {
                didTapNextButton()
            }
            .submitLabel(.next)
            .style(intensity: .supershy)
            .shakeAnimation(forNumberOfAttempts: model.invalidPasswordAttempts)
        }
    }

    private var confirmationField: some View {
        LoginFieldBox {
            TextInput(L10n.Localizable.createAccountReEnterPassword,
                      text: $model.confirmationPassword)
            .textInputIsSecure(true)
            .focused($confirmationMasterPasswordFocused)
            .onSubmit {
                model.validateMasterPasswordConfirmation()
            }
            .submitLabel(.go)
            .style(intensity: .supershy)
            .shakeAnimation(forNumberOfAttempts: model.invalidPasswordAttempts)
        }
        .transition(AnyTransition.move(edge: .bottom)
        .combined(with: .opacity))
    }

    private var textFields: some View {
        VStack(spacing: 4) {
            initialEntryField

            if model.step == .masterPasswordConfirmation {
                confirmationField
            }
        }
    }

    private var passwordStrengthView: some View {
        VStack(alignment: .leading, spacing: 5) {
            model.passwordStrength.map {
                ProgressBarView(passwordStrength: $0)
            }

            if model.passwordStrength == nil {
                Text(model.passwordStrengthMessage)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .font(.caption)
                .foregroundColor(.ds.text.neutral.standard)
                .fixedSize(horizontal: false, vertical: true)
            } else {
                HStack {
                    Spacer()
                    Text(model.passwordStrengthMessage)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .font(.body)
                        .foregroundColor(.ds.text.neutral.standard)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 15)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    @ViewBuilder
    private var inputFeedbackLabel: some View {
        if model.password != "" && model.password == model.confirmationPassword {
            matchingLabel
        }

        if let error = model.errorLabel {
            errorLabel(for: error)
        }
    }

    private var matchingLabel: some View {
        HStack {
            Spacer()
            Text(L10n.Localizable.minimalisticOnboardingMasterPasswordConfirmationPasswordsMatching)
                .font(.callout)
                .foregroundColor(.ds.text.neutral.standard)
                .padding(.top, 8)
            Spacer()
        }
    }

    private func errorLabel(for error: String) -> some View {
        HStack {
            Spacer()
            Text(error)
                .font(.callout)
                .foregroundColor(.ds.text.neutral.standard)
                .padding(.top, 8)
            Spacer()
        }
    }

    private func styledTitle(_ title: String) -> some View {
        return Text(title)
            .font(DashlaneFont.custom(24, .medium).font)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(.ds.text.neutral.catchy)
    }

    private func styledSubtitle(_ title: String) -> some View {
        return Text(title)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .font(.body)
            .foregroundColor(.ds.text.neutral.standard)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var needHelpLabel: some View {
        let text = L10n.Localizable.createAccountNeedHelp + " **" + L10n.Localizable.createAccountSeeTips + "** →"
        return MarkdownText(text)
            .font(.body)
            .foregroundColor(.ds.text.brand.standard)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func didTapNextButton() {
        withAnimation {
            model.next()
        }
    }

    private func didTapBackButton() {
        withAnimation {
            model.back()
        }
    }
}

extension NewMasterPasswordView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        return .transparent(tintColor: .ds.text.inverse.standard, statusBarStyle: .default)
    }
}

struct NewMasterPasswordView_Previews: PreviewProvider {
    static let evaluator: PasswordEvaluator = {
        do {
            return try PasswordEvaluator()
        } catch {
            fatalError()
        }
    }()

    static let logger = AccountCreationInstallerLogger(installerLogService: InstallerLogService.mock)

    static var previews: some View {
                MultiContextPreview {
            NavigationView {
                NewMasterPasswordView(model: NewMasterPasswordViewModel(mode: .accountCreation, evaluator: evaluator, logger: logger, keychainService: .fake, activityReporter: .fake, step: .masterPasswordCreation) { _ in
                }, title: "Create Account")
            }.previewDisplayName("Account creation")

            NavigationView {
                NewMasterPasswordView(model: NewMasterPasswordViewModel(mode: .accountCreation, evaluator: evaluator, logger: logger, keychainService: .fake, activityReporter: .fake, step: .masterPasswordConfirmation) { _ in
                }, title: "Create Account")
            }.previewDisplayName("Account creation")
        }

                MultiContextPreview {
            NavigationView {
                NewMasterPasswordView(model: NewMasterPasswordViewModel(mode: .masterPasswordChange, evaluator: evaluator, logger: logger, keychainService: .fake, activityReporter: .fake, step: .masterPasswordCreation) { _ in
                }, title: "Create Account")
            }.previewDisplayName("Master password change")

            NavigationView {
                NewMasterPasswordView(model: NewMasterPasswordViewModel(mode: .masterPasswordChange, evaluator: evaluator, logger: logger, keychainService: .fake, activityReporter: .fake, step: .masterPasswordConfirmation) { _ in
                }, title: "Create Account")
            }.previewDisplayName("Master password change")
        }
    }
}
