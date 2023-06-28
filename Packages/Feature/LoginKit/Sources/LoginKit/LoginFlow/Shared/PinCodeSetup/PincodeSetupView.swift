#if canImport(UIKit)
import Foundation
import SwiftUI
import CoreLocalization
import DesignSystem
import UIComponents
import CoreKeychain
import DashTypes

struct PinCodeSetupView: View {

    @StateObject
    var model: PinCodeSetupViewModel

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Core.loginPinSetupTitle)
                .font(.custom(GTWalsheimPro.regular.name,
                              size: 28,
                              relativeTo: .title)
                    .weight(.medium))
            Text(L10n.Core.loginPinSetupMessage)
                .font(.body)
            Spacer()
            buttonsView
        }.padding(24)
            .fullScreenCover(isPresented: $model.choosePinCode) {
                PinCodeSelection(model: model.makePinCodeViewModel())
            }
            .loginAppearance()
            .navigationBarBackButtonHidden()
    }

    var buttonsView: some View {
        VStack(spacing: 8) {
            Spacer()
            RoundedButton(L10n.Core.loginPinSetupCta, action: {
                model.choosePinCode = true
            })
            .roundedButtonLayout(.fill)
            RoundedButton(L10n.Core.cancel, action: {
                dismiss()
            })
            .style(mood: .brand, intensity: .quiet)
            .roundedButtonLayout(.fill)
        }
    }
}

struct PinCodeSetupView_Previews: PreviewProvider {
    static var previews: some View {
        PinCodeSetupView(model: PinCodeSetupViewModel(login: Login(""), completion: {_ in}))
    }
}
#endif
