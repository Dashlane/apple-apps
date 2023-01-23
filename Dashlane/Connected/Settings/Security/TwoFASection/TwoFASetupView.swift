import Foundation
import SwiftUI
import SwiftTreats
import DashTypes

struct TwoFASetupView: View {

    @StateObject
    var model: TwoFASetupViewModel

    @Binding
    var appStoreViewer: AppStoreProductViewer?

    @Environment(\.dismiss)
    var dismiss

    let completion: () -> Void

    var body: some View {
        ZStack {
            switch model.activationAction {
            case .enableLock:
                notPairedView
            case .downloadAuthApp:
                DownloadAuthenticatorView(model: DownloadAuthenticatorViewModel {page in
                    self.appStoreViewer = page
                    completion()
                })
            case .setupTwoFA:
                TwoFAActivationView(model: model.twoFAActivationViewModelFactory.make())
            }
        } .overFullScreen(isPresented: $model.displayPinCodeSelection) {
            PinCodeSelection(model: model.makePinCodeSelectionViewModel())
        }
    }

    var notPairedView: some View {
        NavigationView {
            FeedbackView(title: L10n.Localizable.twofaSetupUnpairedTitle(Device.currentBiometryDisplayableName),
                         message: L10n.Localizable.twofaSetupUnpairedMessage1(Device.currentBiometryDisplayableName) + "\n\n" + L10n.Localizable.twofaSetupUnpairedMessage2,
                         kind: .twoFA,
                         helpCTA: (L10n.Localizable.twofaSetupUnpairedHelpCta, DashlaneURLFactory.aboutAuthenticator),
                         primaryButton: primaryButton,
                         secondaryButton: secondaryButton)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: completion, label: {
                        Text(L10n.Localizable.cancel)
                            .foregroundColor(.ds.text.neutral.standard)
                    })
                }
            })
        }
    }

    var primaryButton: (String, () -> Void) {
        if let biometry = Device.biometryType?.displayableName {
            return (L10n.Localizable.twofaSetupBiometryCta(biometry), {
                do {
                    try model.enableBiometry()
                    dismiss()
                } catch {}
            })
        } else {
            return pinButton
        }
    }

    var secondaryButton: (String, () -> Void)? {
        if Device.biometryType != nil {
            return pinButton
        } else {
            return nil
        }
    }

    var pinButton: (String, () -> Void) {
       return (L10n.Localizable.twofaSetupPinCta, { model.displayPinCodeSelection = true })
    }
}

struct TwoFASetupView_Previews: PreviewProvider {
    static var previews: some View {
        TwoFASetupView(model: .mock, appStoreViewer: .constant(nil), completion: {})
    }
}
