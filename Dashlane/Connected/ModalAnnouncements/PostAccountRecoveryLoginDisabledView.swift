import Foundation
import SwiftUI
import UIComponents
import DesignSystem
import CoreSession

struct PostAccountRecoveryLoginDisabledView: View {

    enum Completion {
        case goToSettings
        case cancel
    }

    let authenticationMethod: AuthenticationMethod
    let completion: (Completion) -> Void

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        ScrollView {
            mainView
                .navigationBarStyle(.transparent)
                .navigationBarBackButtonHidden(true)
                .hiddenNavigationTitle()
        }
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .overlay(overlayButton)
    }

    var mainView: some View {
        VStack(alignment: .leading, spacing: 33) {
            Image.ds.recoveryKey.outlined
                .resizable()
                .frame(width: 77, height: 77)
                .foregroundColor(.ds.text.brand.quiet)
                .padding(.horizontal, 16)
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.Localizable.postLoginRecoveryKeyDisabledTitle)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.custom(GTWalsheimPro.regular.name,
                                  size: 28,
                                  relativeTo: .title)
                        .weight(.medium))
                    .foregroundColor(.ds.text.neutral.catchy)
                textBody(Text(authenticationMethod.message))
                textBody(Text(L10n.Localizable.postLoginRecoveryKeyDisabledMessage))
                    .padding(.top, 16)
            }
            Spacer()
        }.padding(.all, 24)
            .padding(.bottom, 24)
    }

    var overlayButton: some View {
        VStack(spacing: 8) {
            Spacer()
            RoundedButton(L10n.Localizable.postLoginRecoveryKeyDisabledCta, action: { completion(.goToSettings) })
                .roundedButtonLayout(.fill)
            RoundedButton(L10n.Localizable.postLoginRecoveryKeyDisabledCancel, action: {
                dismiss()
            })
            .roundedButtonLayout(.fill)
            .style(mood: .brand, intensity: .quiet)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    func textBody(_ text: Text) -> some View {
        text
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(.ds.text.neutral.standard)
            .font(.body)
    }
}

struct PostAccountRecoveryLoginDisabledView_Previews: PreviewProvider {
    static var previews: some View {
        PostAccountRecoveryLoginDisabledView(authenticationMethod: .masterPassword(""), completion: {_ in })
        PostAccountRecoveryLoginDisabledView(authenticationMethod: .invisibleMasterPassword(""), completion: {_ in })
    }
}

private extension AuthenticationMethod {
    var message: String {
        switch self {
        case .invisibleMasterPassword, .sso:
            return L10n.Localizable.postLoginRecoveryKeyDisabledMplessMessage
        case .masterPassword:
            return L10n.Localizable.postLoginRecoveryKeyDisabledMpMessage
        }
    }
}
