#if canImport(UIKit)
import Foundation
import SwiftUI
import Combine
import CorePasswords
import DashTypes
import UIDelight
import UIComponents
import DesignSystem
import CoreKeychain
import CoreLocalization

public struct NewMasterPasswordView<Accessory: View>: View {
    @StateObject private var model: NewMasterPasswordViewModel
    private let title: String

    @State private var showPasswordTips: Bool = false
    @State private var confirmationFieldFeedbackAppearance: TextFieldFeedbackAppearance?
    @FocusState private var creationMasterPasswordFocused: Bool
    @FocusState private var confirmationMasterPasswordFocused: Bool
    @AccessibilityFocusState var errorFocus
    private let accessory: Accessory

    var backButtonTitle: String {
        switch model.step {
        case .masterPasswordCreation:
            return L10n.Core.minimalisticOnboardingMasterPasswordSecondBack
        case .masterPasswordConfirmation:
            return L10n.Core.minimalisticOnboardingMasterPasswordSecondConfirmationBack
        }
    }

    public init(model: @autoclosure @escaping () -> NewMasterPasswordViewModel, title: String, @ViewBuilder accessory: () -> Accessory) {
        _model = .init(wrappedValue: model())
        self.title = title
        self.accessory = accessory()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            description
            textFields
        }
        .padding(.horizontal, 24)
        .frame(maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .bottom) {
            VStack(spacing: 10) {
                if model.step == .masterPasswordCreation {
                    accessory
                        .padding(.bottom, 10)
                        .padding(.horizontal, 24)
                    tipsButton
                }
                KeyboardSpacer()
            }
        }
        .reportPageAppearance(.accountCreationCreateMasterPassword)
        .onReceive(model.stepOnFocusPublisher.delay(for: .seconds(0.5),
                                                    scheduler: RunLoop.main),
                   perform: focusTextField(for:))
        .newLoginAppearance()
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
                .disabled(!model.canCreate)
            }
        }
        .onAppear {
            self.model.focusActivated = true
        }
        .onChange(of: model.errorLabel) { newValue in
            withAnimation(.easeOut(duration: 0.2)) {
                confirmationFieldFeedbackAppearance = newValue != nil ? .error : nil
            }
            
            guard let newValue, !newValue.isEmpty else {
                return
            }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.errorFocus = true
            }
        }
    }

    @ViewBuilder
    var nextButtonLabel: some View {
        switch model.step {
        case .masterPasswordCreation:
            Text(L10n.Core.minimalisticOnboardingMasterPasswordSecondNext)
                .bold(model.canCreate == true)
        case .masterPasswordConfirmation:
            Text(L10n.Core.minimalisticOnboardingMasterPasswordSecondConfirmationNext)
                .bold(model.password == model.confirmationPassword && model.canCreate == true)
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

    private var description: some View {
        VStack(alignment: .leading, spacing: 8) {
            if model.step == .masterPasswordCreation {
                switch model.mode {
                case .accountCreation:
                    styledTitle(L10n.Core.NewMasterPassword.title)
                case .masterPasswordChange:
                    styledTitle(L10n.Core.mpchangeNewMasterPassword)
                }
                styledSubtitle(L10n.Core.masterPasswordCreationSubtitle)
            } else {
                styledTitle(L10n.Core.minimalisticOnboardingMasterPasswordConfirmationTitle)
                styledSubtitle(L10n.Core.minimalisticOnboardingMasterPasswordConfirmationSubtitle)
            }

        }
        .padding(.top, 24)
        .padding(.bottom, 24)
    }

    private var initialEntryField: some View {
        DS.PasswordField(
            CoreLocalization.L10n.Core.masterPassword,
            placeholder: L10n.Core.minimalisticOnboardingMasterPasswordSecondPlaceholder,
            text: $model.password,
            feedback: {
                if let passwordStrength = model.passwordStrength.flatMap(TextFieldPasswordStrengthFeedback.Strength.init(strength:)) {
                    TextFieldPasswordStrengthFeedback(strength: passwordStrength)
                        .transition(.opacity)
                }
            }
        )
        .focused($creationMasterPasswordFocused)
        .onSubmit {
            didTapNextButton()
        }
        .submitLabel(.next)
        .shakeAnimation(forNumberOfAttempts: model.invalidPasswordAttempts)
    }

    private var confirmationField: some View {
        DS.PasswordField(
            CoreLocalization.L10n.Core.newMasterPasswordConfirmationLabel,
            placeholder: L10n.Core.createAccountReEnterPassword,
            text: $model.confirmationPassword,
            feedback: {
                if !model.password.isEmpty && model.password == model.confirmationPassword {
                    TextFieldTextualFeedback(L10n.Core.minimalisticOnboardingMasterPasswordConfirmationPasswordsMatching)
                }
                if let error = model.errorLabel {
                    TextFieldTextualFeedback(error)
                        .fiberAccessibilityFocus($errorFocus)
                }
            }
        )
        .textFieldFeedbackAppearance(confirmationFieldFeedbackAppearance)
        .focused($confirmationMasterPasswordFocused)
        .onSubmit {
            model.validateMasterPasswordConfirmation()
        }
        .submitLabel(.go)
        .shakeAnimation(forNumberOfAttempts: model.invalidPasswordAttempts)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var textFields: some View {
        VStack(spacing: 16) {
            initialEntryField

            if model.step == .masterPasswordConfirmation {
                confirmationField
            }
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
        Text(L10n.Core.createAccountSeeTips)
            .bold()
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
    
    var tipsButton: some View {
        Button(action: { self.showPasswordTips = true }, label: {
            needHelpLabel
        })
        .accessibilityLabel("\(L10n.Core.createAccountNeedHelp) \(L10n.Core.createAccountSeeTips)")
        .sheet(isPresented: $showPasswordTips) {
            PasswordTipsView { _ in
            }
        }
    }
}

public extension NewMasterPasswordView where Accessory == EmptyView {
    init(model: NewMasterPasswordViewModel, title: String) {
        self.init(model: model, title: title) {
            EmptyView()
        }
    }
}

private extension TextFieldPasswordStrengthFeedback.Strength {
    init?(strength: PasswordStrength) {
        self.init(rawValue: strength.rawValue + 1)
    }
}

extension NewMasterPasswordView: NavigationBarStyleProvider {
    public var navigationBarStyle: UIComponents.NavigationBarStyle {
        .transparent(tintColor: .ds.text.inverse.standard, statusBarStyle: .default)
    }
}

struct NewMasterPasswordView_Previews: PreviewProvider {
    static var previews: some View {
                NavigationView {
            NewMasterPasswordView(
                model: NewMasterPasswordViewModel(
                    mode: .accountCreation,
                    evaluator: .mock(),
                    keychainService: .fake,
                    activityReporter: .fake,
                    step: .masterPasswordCreation) { _ in },
                title: "Create Account"
            )
        }
        .previewDisplayName("Account creation")

        NavigationView {
            NewMasterPasswordView(
                model: NewMasterPasswordViewModel(
                    mode: .accountCreation,
                    evaluator: .mock(),
                    keychainService: .fake,
                    activityReporter: .fake,
                    step: .masterPasswordConfirmation) { _ in },
                title: "Account Creation"
            )
        }
        .previewDisplayName("Account creation")

                NavigationView {
            NewMasterPasswordView(
                model: NewMasterPasswordViewModel(
                    mode: .masterPasswordChange,
                    evaluator: .mock(),
                    keychainService: .fake,
                    activityReporter: .fake,
                    step: .masterPasswordCreation) { _ in },
                title: "Create Account"
            )
        }
        .previewDisplayName("Master password change")

        NavigationView {
            NewMasterPasswordView(
                model: NewMasterPasswordViewModel(
                    mode: .masterPasswordChange,
                    evaluator: .mock(),
                    keychainService: .fake,
                    activityReporter: .fake,
                    step: .masterPasswordConfirmation) { _ in },
                title: "Create Account"
            )
        }
        .previewDisplayName("Master password change")
    }
}
#endif
