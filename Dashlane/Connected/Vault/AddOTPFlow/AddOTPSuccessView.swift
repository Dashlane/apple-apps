import Foundation
import SwiftUI
import CorePersonalData
import TOTPGenerator
import UIComponents
import DesignSystem
import VaultKit

struct AddOTPSuccessView: View {

    enum Mode {
        case credentialPrefilled(Credential)
        case promptToEnterCredential(configuration: OTPConfiguration)
    }
    let mode: Mode
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Spacer()
            Image.ds.feedback.success.outlined
                .resizable()
                .foregroundColor(.ds.text.brand.standard)
                .aspectRatio(contentMode: .fit)
                .frame(width: 62)
                .fiberAccessibilityHidden(true)

            VStack(alignment: .center, spacing: 16) {

                Text(L10n.Localizable._2faSetupSuccessTitle(domainName)).font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
            }
            Text(description)
                .font(.body)
                .foregroundColor(.ds.text.neutral.standard)

            Spacer()

            RoundedButton(buttonTitle, action: action)
                .roundedButtonLayout(.fill)
        }.padding(.horizontal, 24)
            .padding(.vertical, 24)
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

    }

    private var domainName: String {
        switch mode {
        case let .credentialPrefilled(credential):
            return credential.displayTitle
        case let .promptToEnterCredential(configuration):
            return configuration.issuerOrTitle
        }
    }

    private var buttonTitle: String {
        switch mode {
        case .credentialPrefilled:
            return L10n.Localizable.modalOkGotIt
        case .promptToEnterCredential:
            return L10n.Localizable.otptoolAddLoginCta
        }
    }

    var description: String {
        return L10n.Localizable._2fasetupSuccessSubtitle
    }
}

struct AddOTPSuccessView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            AddOTPSuccessView(mode: .credentialPrefilled(PersonalDataMock.Credentials.wikipedia), action: {})
            AddOTPSuccessView(mode: .promptToEnterCredential(configuration: .mock), action: {})
            .preferredColorScheme(.dark)
        }
    }

}
