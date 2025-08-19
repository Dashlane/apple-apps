import Combine
import CoreKeychain
import CoreLocalization
import CorePasswords
import CoreTypes
import DesignSystem
import DesignSystemExtra
import Foundation
import SwiftUI
import UIComponents
import UIDelight

public struct NewMasterPasswordView<Accessory: View>: View {
  @StateObject private var model: NewMasterPasswordViewModel
  private let title: String

  @State private var showPasswordTips: Bool = false
  @State private var confirmationFieldStyle: Style?
  @FocusState private var creationMasterPasswordFocused: Bool
  @FocusState private var confirmationMasterPasswordFocused: Bool
  @AccessibilityFocusState var errorFocus
  private let accessory: Accessory

  var backButtonTitle: String {
    switch model.step {
    case .masterPasswordCreation:
      return CoreL10n.minimalisticOnboardingMasterPasswordSecondBack
    case .masterPasswordConfirmation:
      return CoreL10n.minimalisticOnboardingMasterPasswordSecondConfirmationBack
    }
  }

  public init(
    model: @autoclosure @escaping () -> NewMasterPasswordViewModel, title: String,
    @ViewBuilder accessory: () -> Accessory
  ) {
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
      if model.step == .masterPasswordCreation {
        VStack(spacing: 10) {
          Button(CoreL10n.createMasterPasswordAccountCta) {
            model.next()
          }
          .buttonStyle(.designSystem(.titleOnly))
          .disabled(!model.canCreate)
          .style(mood: .brand, intensity: .catchy)

          accessory
        }
        .padding(.bottom, 10)
        .padding(.horizontal, 24)
      }
    }
    .reportPageAppearance(.accountCreationCreateMasterPassword)
    .onReceive(
      model.stepOnFocusPublisher.delay(
        for: .seconds(0.5),
        scheduler: RunLoop.main),
      perform: focusTextField(for:)
    )
    .loginAppearance()
    .navigationBarBackButton(action: didTapBackButton)
    .toolbar {
      if model.mode == .masterPasswordChange || model.step == .masterPasswordConfirmation {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: didTapNextButton) {
            nextButtonLabel
          }
          .disabled(!model.canCreate)
        }
      }
    }
    .onAppear {
      self.model.focusActivated = true
    }
    .onChange(of: model.errorLabel) { _, newValue in
      withAnimation(.easeOut(duration: 0.2)) {
        confirmationFieldStyle = newValue != nil ? .error : nil
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
      Text(CoreL10n.minimalisticOnboardingMasterPasswordSecondNext)
        .bold(model.canCreate == true)
    case .masterPasswordConfirmation:
      Text(CoreL10n.minimalisticOnboardingMasterPasswordSecondConfirmationNext)
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
          styledTitle(CoreL10n.NewMasterPassword.title)
        case .masterPasswordChange:
          styledTitle(CoreL10n.mpchangeNewMasterPassword)
        }
        tipsButton
      } else {
        styledTitle(CoreL10n.minimalisticOnboardingMasterPasswordConfirmationTitle)
        styledSubtitle(CoreL10n.minimalisticOnboardingMasterPasswordConfirmationSubtitle)
      }

    }
    .padding(.top, 24)
    .padding(.bottom, 24)
  }

  private var initialEntryField: some View {
    DS.PasswordField(
      CoreL10n.masterPassword,
      placeholder: CoreL10n.minimalisticOnboardingMasterPasswordSecondPlaceholder,
      text: $model.password,
      feedback: {
        if let passwordStrength = model.passwordStrength.flatMap(
          TextInputPasswordStrengthFeedback.Strength.init(strength:))
        {
          TextInputPasswordStrengthFeedback(strength: passwordStrength)
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
      CoreL10n.newMasterPasswordConfirmationLabel,
      placeholder: CoreL10n.createAccountReEnterPassword,
      text: $model.confirmationPassword,
      feedback: {
        if !model.password.isEmpty && model.password == model.confirmationPassword {
          FieldTextualFeedback(
            CoreL10n.minimalisticOnboardingMasterPasswordConfirmationPasswordsMatching)
        }
        if let error = model.errorLabel {
          FieldTextualFeedback(error)
            .fiberAccessibilityFocus($errorFocus)
        }
      }
    )
    .style(confirmationFieldStyle)
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
      .textStyle(.title.section.medium)
      .multilineTextAlignment(.leading)
      .lineLimit(nil)
      .fixedSize(horizontal: false, vertical: true)
      .foregroundStyle(Color.ds.text.neutral.catchy)
  }

  private func styledSubtitle(_ title: String) -> some View {
    return Text(title)
      .multilineTextAlignment(.leading)
      .lineLimit(nil)
      .font(.body)
      .foregroundStyle(Color.ds.text.neutral.standard)
      .fixedSize(horizontal: false, vertical: true)
  }

  private var needHelpLabel: some View {
    Text(CoreL10n.createAccountSeeTips)
      .bold()
      .font(.body)
      .foregroundStyle(Color.ds.text.brand.standard)
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
    Button(
      action: { self.showPasswordTips = true },
      label: {
        needHelpLabel
      }
    )
    .accessibilityLabel("\(CoreL10n.createAccountNeedHelp) \(CoreL10n.createAccountSeeTips)")
    .sheet(isPresented: $showPasswordTips) {
      PasswordTipsView { _ in
      }
    }
  }
}

extension NewMasterPasswordView where Accessory == EmptyView {
  public init(
    model: @escaping @autoclosure () -> NewMasterPasswordViewModel,
    title: String
  ) {
    self.init(model: model(), title: title) {
      EmptyView()
    }
  }
}

extension TextInputPasswordStrengthFeedback.Strength {
  fileprivate init?(strength: PasswordStrength) {
    self.init(rawValue: strength.rawValue + 1)
  }
}

struct NewMasterPasswordView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      NewMasterPasswordView(
        model: NewMasterPasswordViewModel(
          mode: .accountCreation,
          evaluator: .mock(),
          keychainService: .mock,
          activityReporter: .mock,
          step: .masterPasswordCreation
        ) { _ in },
        title: "Create Account"
      )
    }
    .previewDisplayName("Account creation")

    NavigationView {
      NewMasterPasswordView(
        model: NewMasterPasswordViewModel(
          mode: .accountCreation,
          evaluator: .mock(),
          keychainService: .mock,
          activityReporter: .mock,
          step: .masterPasswordConfirmation
        ) { _ in },
        title: "Account Creation"
      )
    }
    .previewDisplayName("Account creation")

    NavigationView {
      NewMasterPasswordView(
        model: NewMasterPasswordViewModel(
          mode: .masterPasswordChange,
          evaluator: .mock(),
          keychainService: .mock,
          activityReporter: .mock,
          step: .masterPasswordCreation
        ) { _ in },
        title: "Create Account"
      )
    }
    .previewDisplayName("Master password change")

    NavigationView {
      NewMasterPasswordView(
        model: NewMasterPasswordViewModel(
          mode: .masterPasswordChange,
          evaluator: .mock(),
          keychainService: .mock,
          activityReporter: .mock,
          step: .masterPasswordConfirmation
        ) { _ in },
        title: "Create Account"
      )
    }
    .previewDisplayName("Master password change")
  }
}
