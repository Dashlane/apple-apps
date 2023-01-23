import SwiftUI
import CoreSession
import DashTypes
import UIDelight
import LoginKit

struct PinUnlockView: View {

    @StateObject
    var model: PinUnlockViewModel
    
    @State var openContactSupport = false
    
    init(model: @autoclosure @escaping () -> PinUnlockViewModel) {
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
                    self.openContactSupport = true
                }))
                .safariSheet(isPresented: $openContactSupport, .troubleshooting)
            }
    }
    
    var mainView: some View {
        VStack {
            topView
            Spacer()
            centerView
            Spacer()
        }.padding()
    }
    
    var topView: some View {
        VStack {
            Image(asset: AuthenticatorAsset.logoLockUp)
                .foregroundColor(Color(asset: AuthenticatorAsset.oddityBrand))
            Text(model.login.email)
                .foregroundColor(.ds.text.neutral.standard)
                .font(.body)
        }
    }
    
    var centerView: some View {
        PinCodeView(pinCode: $model.enteredPincode,
                    errorMessage: $model.errorMessage,
                    attempt: model.attempts,
                    hideCancel: true,
                    cancelAction: {})
            .padding()
    }
}

struct PinUnlockView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            NavigationView {
                PinUnlockView(model: PinUnlockViewModel(login: Login("_"), pin: "1234", pinCodeAttempts: .mock, masterKey: .masterPassword("Azerty12"), validateMasterKey: {_ in throw AccountError.unknown }, completion: {_ in}))
            }
        }
    }
}
