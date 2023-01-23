import SwiftUI
import SwiftTreats
import CoreSync
import UIDelight
import CoreSession
import DashTypes
import TOTPGenerator
import CoreNetworking
import UIComponents

struct TwoFASettingsView: View {

            enum NextPossibleActionSheet: Identifiable {
        var id: String {
            switch self {
            case .activation:
                return "activation"
            case .deactivation:
                return "deactivation"
            case .twoFAEnforced:
                return "twoFAEnforced"
            }
        }
        case activation
        case deactivation(Dashlane2FAType)
        case twoFAEnforced
    }

    @StateObject
    var model: TwoFASettingsViewModel

    @State
    var appStoreViewer: AppStoreProductViewer?

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack {
            if model.status == .loaded {
                Toggle(L10n.Localizable.twofaSettingsTitle, isOn: $model.isTFAEnabled)
                    .onTapGesture {
                        model.update()
                    }
            } else {
                HStack {
                    Text(L10n.Localizable.twofaSettingsTitle)
                    Spacer()
                    ProgressView()
                }
            }
        }
        .fullScreenCover(item: $model.sheet,
                         onDismiss: {
            Task {
                await model.updateState()
            }
            openAppStoreViewIfPossible()
        },
                         content: { item in
            switch item {
            case .activation:
                TwoFASetupView(model: model.twoFASetupViewModelFactory.make(), appStoreViewer: $appStoreViewer, completion: {
                    self.model.sheet = nil
                })
            case let .deactivation(currentOtp):
                TwoFADeactivationView(model: model.makeTwoFADeactivationViewModel(currentOtp: currentOtp))
            case .twoFAEnforced:
               TwoFactorEnforcementView(model: model.makeTwoFactorEnforcementViewModel())
            }})
        .alert(isPresented: $model.showDeactivationAlert) {
            Alert(title: Text(L10n.Localizable.twofaDeactivationAlertTitle),
                  message: Text(L10n.Localizable.twofaDeactivationAlertMessage),
                  primaryButton: SwiftUI.Alert.Button.cancel({
                Task {
                   await model.fetch()
                }
            }), secondaryButton: Alert.Button.destructive(Text(L10n.Localizable.twofaDeactivationAlertCta), action: {
                if let currentOTP = model.currentOTP {
                    model.sheet = .deactivation(currentOTP)
                }
            }))
        }
    }

    var notPairedView: some View {
        NavigationView {
            FeedbackView(title: L10n.Localizable.twofaSetupUnpairedTitle(Device.currentBiometryDisplayableName),
                         message: L10n.Localizable.twofaSetupUnpairedMessage1(Device.currentBiometryDisplayableName) + "\n\n" + L10n.Localizable.twofaSetupUnpairedMessage2,
                         kind: .twoFA,
                         helpCTA: (L10n.Localizable.twofaSetupUnpairedHelpCta, DashlaneURLFactory.aboutAuthenticator),
                         primaryButton: (L10n.Localizable.twofaSetupUnpairedCta, {
                model.sheet = nil
            }))
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        model.sheet = nil
                    }, label: {
                        Text(L10n.Localizable.cancel)
                            .foregroundColor(.ds.text.neutral.standard)
                    })
                }
            })
        }
    }

    func openAppStoreViewIfPossible() {
        DispatchQueue.main.async {
                        appStoreViewer?.openAppStorePage(dismissed: {})
            appStoreViewer = nil
        }
    }
}

 struct TwoFASettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TwoFASettingsView(model: .mock)
    }
 }
