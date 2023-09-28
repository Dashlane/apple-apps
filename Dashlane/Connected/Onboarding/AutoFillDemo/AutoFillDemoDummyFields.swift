import SwiftUI
import CorePersonalData
import Lottie
import UIDelight
import UIComponents
import DesignSystem
import CoreLocalization

struct AutoFillDemoDummyFields: View {

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var shouldReveal: Bool = false
    @State private var shouldShowSetupButton: Bool = false
    @FocusState private var isEmailFieldEditing: Bool
    @State private var isPasswordFieldEditing: Bool = false

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
        GeometryReader { proxy in
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)

                VStack {
                    if shouldShowCelebrationAnimation {
                        LottieView(.onboardingConfettis, loopMode: .playOnce,
                                   contentMode: .scaleAspectFit)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .transition(.asymmetric(insertion: .identity, removal: .opacity))
                    }
                }.animation(.default, value: shouldShowCelebrationAnimation)

                VStack {
                    VStack(alignment: .leading) {
                        backButton

                        Spacer()

                        contentView.frame(maxWidth: 550, maxHeight: 890)

                        Spacer()
                        RoundedButton(CoreLocalization.L10n.Core.autofillDemoFieldsAction,
                                      action: { self.completion?(.setupAutofill) })
                        .roundedButtonLayout(.fill)
                        .hidden(!shouldShowSetupButton)
                    }
                    .padding(.horizontal, 24)

                    autofillAccessoryView
                        .opacity(shouldShowAccessoryView ? 1 : 0)
                        .animation(Animation.linear(duration: 0.2), value: shouldShowAccessoryView)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .center) {
            Text(L10n.Localizable.autofillDemoFieldsTitle)
                .font(DashlaneFont.custom(26.0, .bold).font)
                .padding(.bottom, 8)
            Text(L10n.Localizable.autofillDemoFieldsSubtitle)
                .font(.callout)
                .foregroundColor(Color(asset: FiberAsset.neutralText))
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
        Button(action: {
            dismiss()
            completion?(.back)
        }, label: {
            Text(CoreLocalization.L10n.Core.kwBack).font(.body)
        }).foregroundColor(.ds.text.neutral.standard)
    }

    @ViewBuilder
    private var emailTextField: some View {
        TextField(CoreLocalization.L10n.Core.kwEmailIOS, text: $email)
            .focused($isEmailFieldEditing)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .submitLabel(.go)
            .padding(16)
            .font(.callout)
            .frame(height: 48)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(asset: FiberAsset.grey04), lineWidth: 1))
            .onTapGesture {
                self.isEmailFieldEditing.toggle()
        }
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
        HStack {
            PasswordField(L10n.Localizable.dwmOnboardingFixBreachesDetailPassword, text: $password, isFocused: $isPasswordFieldEditing)
                .textContentType(.password)
                .passwordFieldSecure(!shouldReveal)
                .submitLabel(.go)
                .padding(16)
                .font(.callout)

            Button(action: {
                self.shouldReveal.toggle()
            }, label: {
                (shouldReveal ? Image.ds.action.hide.outlined : Image.ds.action.reveal.outlined)
                    .foregroundColor(.ds.text.brand.quiet)
            })
            .hidden(password.isEmpty)
            .fiberAccessibilityLabel(Text(shouldReveal ? CoreLocalization.L10n.Core.kwHide : CoreLocalization.L10n.Core.kwReveal))
            .padding(16)
        }
        .frame(height: 48)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(asset: FiberAsset.grey04), lineWidth: 1))
        .padding(.bottom, 8)
        .onTapGesture {
            self.isPasswordFieldEditing.toggle()
        }
    }
}

extension AutoFillDemoDummyFields: NavigationBarStyleProvider {
    var navigationBarStyle: UIComponents.NavigationBarStyle {
        return .hidden(statusBarStyle: .default)
    }
}

struct AutoFillDemoDummyFields_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AutoFillDemoDummyFields(autoFillDomain: "domain.com", autoFillEmail: "email.com", autoFillPassword: "password", completion: nil)
        }
    }
}
