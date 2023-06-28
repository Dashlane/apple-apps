import SwiftUI
import CorePersonalData
import TOTPGenerator
import CoreUserTracking
import CoreFeature

struct CredentialMenu: View {
    let credential: Credential
    let copyAction: (_ detailField: Definition.Field, _ valueToCopy: String) -> Void

    var body: some View {
        if !credential.password.isEmpty {
            CopyMenuButton(L10n.Localizable.copyPassword) {
                copyAction(.password, credential.password)
            }
        }

        if !credential.email.isEmpty {
            CopyMenuButton(L10n.Localizable.copyEmail) {
                copyAction(.email, credential.email)
            }
        }

        if !credential.login.isEmpty {
            CopyMenuButton(L10n.Localizable.copyLogin) {
                copyAction(.login, credential.login)
            }
        }

        if !credential.secondaryLogin.isEmpty {
            CopyMenuButton(L10n.Localizable.copySecondaryLogin) {
                copyAction(.secondaryLogin, credential.secondaryLogin)
            }
        }

        if let otpURL = credential.otpURL, let otpInfo = try? OTPConfiguration(otpURL: otpURL) {
            CopyMenuButton(L10n.Localizable.copyOneTimePassword) {
                copyAction(.otpCode, TOTPGenerator.generate(with: otpInfo.type, for: Date(), digits: otpInfo.digits, algorithm: otpInfo.algorithm, secret: otpInfo.secret))
            }
        }

        if let url = credential.url?.openableURL {
            OpenWebsiteMenuButton(url: url)
        }
    }
}
