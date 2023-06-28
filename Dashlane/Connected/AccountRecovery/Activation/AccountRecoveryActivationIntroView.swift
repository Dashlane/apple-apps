import Foundation
import SwiftUI
import UIComponents
import DesignSystem
import CoreSession
import CoreLocalization

struct AccountRecoveryActivationIntroView: View {

    enum Completion {
        case generateKey
        case cancel
    }

    let authenticationMethod: AuthenticationMethod
    let canSkip: Bool
    let completion: (Completion) -> Void

    @State
    var showSkipAlert = false

    var body: some View {
        ScrollView {
            mainView
                .navigationBarStyle(.transparent)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if !canSkip {
                            Button(action: {
                                completion(.cancel)
                            }, title: CoreLocalization.L10n.Core.cancel)
                        }
                    }
                }
        }
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .overlay(overlayButton)
        .alert(isPresented: $showSkipAlert) {
            Alert(title: Text(L10n.Localizable.mplessRecoverySkipAlertTitle),
                  message: Text(L10n.Localizable.mplessRecoverySkipAlertMessage),
                  primaryButton: .default(Text(L10n.Localizable.mplessRecoverySkipAlertCta), action: {
                completion(.cancel)
            }),
                  secondaryButton: .cancel())
        }
        .navigationTitle(CoreLocalization.L10n.Core.recoveryKeySettingsLabel)
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 33) {
            Image.ds.recoveryKey.outlined
                .resizable()
                .frame(width: 77, height: 77)
                .foregroundColor(.ds.text.brand.quiet)
                .padding(.horizontal, 16)
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.Localizable.recoveryKeyActivationIntroTitle)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.custom(GTWalsheimPro.regular.name,
                                  size: 28,
                                  relativeTo: .title)
                        .weight(.medium))
                    .foregroundColor(.ds.text.neutral.catchy)
                Text(authenticationMethod.message)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.ds.text.neutral.standard)
                    .font(.body)
            }
            Spacer()
        }.padding(.all, 24)
            .padding(.bottom, 24)
    }

    var overlayButton: some View {
        VStack(spacing: 8) {
            Spacer()
            RoundedButton(L10n.Localizable.recoveryKeyActivationIntroCta, action: { completion(.generateKey) })
                .roundedButtonLayout(.fill)
            if canSkip {
                RoundedButton(L10n.Localizable.mplessRecoverySkipCta, action: {
                    showSkipAlert = true
                })
                .roundedButtonLayout(.fill)
                .style(mood: .brand, intensity: .quiet)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

private extension AuthenticationMethod {
    var message: String {
        switch self {
        case .masterPassword:
            return L10n.Localizable.recoveryKeyActivationIntroMessage
        default:
            return L10n.Localizable.mplessRecoveryIntroMessage
        }
    }
}

struct AccountRecoveryActivationIntroView_Previews: PreviewProvider {
    static var previews: some View {
        AccountRecoveryActivationIntroView(authenticationMethod: .masterPassword("Azerty12"), canSkip: false) {_ in}
        AccountRecoveryActivationIntroView(authenticationMethod: .invisibleMasterPassword("Azerty12"), canSkip: true) {_ in}
    }
}
