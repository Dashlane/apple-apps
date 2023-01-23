import Foundation
import SwiftUI
import DashTypes

struct DownloadAuthenticatorView: View {

    @StateObject
    var viewModel: DownloadAuthenticatorViewModel

    @Environment(\.dismiss)
    private var dismiss

    init(model: DownloadAuthenticatorViewModel) {
        _viewModel = .init(wrappedValue: model)
    }

    var body: some View {
        NavigationView {
            FeedbackView(title: L10n.Localizable.downloadAuthAppTitle,
                         message: L10n.Localizable.downloadAuthAppSubtitle + "\n\n\n" + L10n.Localizable.downloadAuthAppMessage1 + "\n\n" + L10n.Localizable.downloadAuthAppMessage2 + "\n",
                         kind: .twoFA,
                         helpCTA: (L10n.Localizable.downloadAuthAppHelpCta, DashlaneURLFactory.aboutAuthenticator),
                         primaryButton: (L10n.Localizable.downloadAuthAppCta, {viewModel.openAppStoreView() }))
            .reportPageAppearance(.settingsSecurityTwoFactorAuthenticationEnableDownloadAuthenticator)
            .toolbar {
                ToolbarItem.init(placement: .navigationBarLeading) {
                    Button(action: { dismiss() },
                           label: { Text(L10n.Localizable.cancel) })
                }
            }
        }

    }
}

struct DownloadAuthenticatorView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadAuthenticatorView(model: DownloadAuthenticatorViewModel(showAppStorePage: {_ in }))
    }
}
