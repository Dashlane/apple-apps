import Foundation
import SwiftUI
import DashTypes
import UIDelight
import LoginKit
import CoreLocalization

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
                         message: L10n.Localizable.downloadAuthAppSubtitle,
                         kind: .twoFA,
                         helpCTA: (L10n.Localizable.downloadAuthAppHelpCta, DashlaneURLFactory.aboutAuthenticator),
                         primaryButton: (L10n.Localizable.downloadAuthAppCta, {viewModel.openAppStoreView() }),
                         accessory: {
                accessorView
            })
            .reportPageAppearance(.settingsSecurityTwoFactorAuthenticationEnableDownloadAuthenticator)
            .toolbar {
                ToolbarItem.init(placement: .navigationBarLeading) {
                    Button(action: { dismiss() },
                           label: { Text(CoreLocalization.L10n.Core.cancel) })
                }
            }
        }

    }

    var accessorView: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text(L10n.Localizable.downloadAuthAppMessage1)
            Text(L10n.Localizable.downloadAuthAppMessage2)
        }
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(.ds.text.neutral.standard)
        .font(.body)
        .padding(.vertical, 32)
    }
}

struct DownloadAuthenticatorView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadAuthenticatorView(model: DownloadAuthenticatorViewModel(showAppStorePage: {_ in }))
    }
}
