import SwiftUI
import SwiftTreats
import CoreSession
import CoreKeychain
import DashTypes
import UIDelight
import LoginKit
import UIComponents
import DesignSystem

enum BiometryAndPinCompletion {
    case success
    case cancel
}

struct BiometryAndPinUnlockView: View {

    @StateObject
    var model: BiometryAndPinUnlockViewModel

    init(model: @autoclosure @escaping () -> BiometryAndPinUnlockViewModel) {
        _model = .init(wrappedValue: model())
    }

    var body: some View {
        mainView
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .navigation(isActive: $model.showError) {
                FeedbackView(title: L10n.Localizable.pinUnlockErrorTitle,
                          message: L10n.Localizable.pinUnlockErrorMessage,
                          helpCTA: (L10n.Localizable.pinUnlockErrorCta, UserSupportURL.changePin.url),
                          primaryButton: (L10n.Localizable.pinUnlockErrorChangeButtonTitle, {
                    UIApplication.shared.open(.passwordAppSettings)
                }),
                          secondaryButton: (L10n.Localizable.pinUnlockErrorSupportButtonTitle, {
                    UIApplication.shared.open(UserSupportURL.troubleshooting.url)
                }))
            }
    }

    var mainView: some View {
        VStack {
            topView
            Spacer()
            centerView
            Spacer()
            if model.showRetry {
                bottomView
            }
        }.padding(.horizontal, 24)
            .padding(.bottom, 24)
    }

    var topView: some View {
        VStack {
            Image(asset: AuthenticatorAsset.logoLockUp)
                .foregroundColor(.ds.text.brand.quiet)
            Text(model.login.email)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .font(.body)
                .foregroundColor(.ds.text.neutral.standard)
        }
    }

    @ViewBuilder
    var centerView: some View {
        switch model.state {
        case .biometry:
            VStack {
                Text(model.showRetry ? L10n.Localizable.biometryUnlockRetryTitle(model.biometryType.displayableName) : L10n.Localizable.biometryUnlockTitle(model.biometryType.displayableName))
                    .font(.body)
                Button(
                    action: {
                        Task {
                            await model.validateBiometry()
                        }
                    },
                    label: {
                        (model.biometryType == .touchId ? Image.ds.fingerprint.outlined : Image.ds.faceId.outlined)
                            .foregroundColor(.ds.text.neutral.standard)
                    }
                ).disabled(model.inProgress)
            }
            .onAppear {
                if !model.inProgress {
                    model.inProgress = true
                    _ = Task {
                        await model.validateBiometry()
                    }
                }
            }
        case .pin:
            PinCodeView(pinCode: $model.enteredPincode, attempt: model.attempts,
                        hideCancel: true, cancelAction: {}).padding()
        }
    }

    var bottomView: some View {
        VStack(spacing: 8) {
            RoundedButton(L10n.Localizable.biometryUnlockErrorRetryButtonTitle) {
                Task {
                    await model.validateBiometry()
                }
            }
            .roundedButtonLayout(.fill)
            RoundedButton(L10n.Localizable.biometryUnlockRetryPinCta) {
                model.showPin()
            }
            .style(mood: .brand, intensity: .quiet)
            .roundedButtonLayout(.fill)
        }
    }
}

struct BiometryAndPinUnlockView_Preview: PreviewProvider {
    static var previews: some View {

        MultiContextPreview(dynamicTypePreview: true) {
            NavigationView {
                BiometryAndPinUnlockView(model: BiometryAndPinUnlockViewModel(login: Login("_"), pin: "1234", pinCodeAttempts: .mock, masterKey: .masterPassword("Azerty12"), biometryType: .faceId, validateMasterKey: { _ in throw AccountError.unknown }, completion: {_ in }))
                    .hiddenNavigationTitle()
            }

            NavigationView {
                BiometryAndPinUnlockView(model: BiometryAndPinUnlockViewModel(login: Login("_"), pin: "1234", pinCodeAttempts: .mock, masterKey: .masterPassword("Azerty12"), biometryType: .touchId, validateMasterKey: { _ in throw AccountError.unknown }, completion: {_ in }))
                    .hiddenNavigationTitle()
            }
        }
    }
}
