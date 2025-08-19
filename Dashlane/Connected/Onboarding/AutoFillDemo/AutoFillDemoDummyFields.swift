import CoreLocalization
import CorePersonalData
import DesignSystem
import Lottie
import SwiftUI
import SwiftUILottie
import UIComponents
import UIDelight

struct AutoFillDemoDummyFields: View {

  @State private var email: String = ""
  @State private var password: String = ""
  @State private var shouldReveal: Bool = false
  @State private var shouldShowSetupButton: Bool = false
  @FocusState private var isEmailFieldEditing: Bool
  @FocusState private var isPasswordFieldEditing: Bool
  @Environment(\.dismiss) var dismiss

  @AutoReverseState(defaultValue: false, autoReverseInterval: 1)
  private var shouldShowCelebrationAnimation: Bool

  private var shouldShowAccessoryView: Bool {
    return isEmailFieldEditing || isPasswordFieldEditing
  }

  enum Completion {
    case back
    case setupAutofill
  }

  public var autoFillDomain: String
  public var autoFillEmail: String
  public var autoFillPassword: String
  public var completion: ((Completion) -> Void)?

  var body: some View {
    ZStack {
      Color(.ds.background.alternate).edgesIgnoringSafeArea(.all)

      VStack {
        if shouldShowCelebrationAnimation {
          LottieView(
            .onboardingConfettis, loopMode: .playOnce,
            contentMode: .scaleAspectFit
          )
          .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
          )
          .transition(.asymmetric(insertion: .identity, removal: .opacity))
        }
      }.animation(.default, value: shouldShowCelebrationAnimation)

      VStack {
        VStack(alignment: .leading) {
          backButton

          Spacer()

          contentView
            .frame(maxWidth: 550, maxHeight: 890)

          Spacer()

          if shouldShowSetupButton {
            Button(CoreL10n.autofillDemoFieldsAction) {
              self.completion?(.setupAutofill)
            }
            .buttonStyle(.designSystem(.titleOnly))
          }
        }
        .padding(.horizontal, 24)

        autofillAccessoryView
          .opacity(shouldShowAccessoryView ? 1 : 0)
          .animation(Animation.linear(duration: 0.2), value: shouldShowAccessoryView)
      }
    }
    .navigationBarBackButtonHidden(true)
  }

  @ViewBuilder
  private var contentView: some View {
    VStack(alignment: .center) {
      Text(L10n.Localizable.autofillDemoFieldsTitle)
        .textStyle(.specialty.spotlight.small)
        .padding(.bottom, 8)
      Text(L10n.Localizable.autofillDemoFieldsSubtitle)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .padding(.bottom, 32)
        .multilineTextAlignment(.center)

      VStack(spacing: 8) {
        emailTextField
        passwordTextField
      }
    }

  }

  @ViewBuilder
  private var backButton: some View {
    Button(
      action: {
        dismiss()
        completion?(.back)
      },
      label: {
        Text(CoreL10n.kwBack).font(.body)
      }
    ).foregroundStyle(Color.ds.text.neutral.standard)
  }

  @ViewBuilder
  private var emailTextField: some View {
    DS.TextField(CoreL10n.kwEmailIOS, text: $email)
      .focused($isEmailFieldEditing)
      .keyboardType(.emailAddress)
      .textContentType(.emailAddress)
      .submitLabel(.go)
  }

  @ViewBuilder
  private var autofillAccessoryView: some View {
    AutoFillAccessoryView(domain: autoFillDomain, email: autoFillEmail) {
      self.email = autoFillEmail
      self.password = autoFillPassword
      self.shouldShowSetupButton = true
      self.shouldShowCelebrationAnimation = true
      self.isEmailFieldEditing = false
      self.isPasswordFieldEditing = false
    }
  }

  @ViewBuilder
  private var passwordTextField: some View {
    DS.PasswordField(
      L10n.Localizable.dwmOnboardingFixBreachesDetailPassword, text: $password,
      shouldReveal: shouldReveal
    )
    .submitLabel(.go)
    .focused($isPasswordFieldEditing)
    .padding(.bottom, 8)
  }
}

struct AutoFillDemoDummyFields_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      AutoFillDemoDummyFields(
        autoFillDomain: "domain.com", autoFillEmail: "email.com", autoFillPassword: "password",
        completion: nil)
    }
  }
}
