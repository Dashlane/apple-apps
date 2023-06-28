import Foundation
import SwiftUI
import UIDelight
import UIComponents
import DesignSystem
import CoreSession
import CoreNetworking
import LoginKit

struct TwoFactorEnforcementView: View {

    @Environment(\.dismiss) var dismiss

    @State
    var showSetupView = false

    @State
    var appStoreViewer: AppStoreProductViewer?

    @StateObject
    var model: TwoFactorEnforcementViewModel

    init(model: @autoclosure @escaping () -> TwoFactorEnforcementViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        NavigationView {
            mainView
                .navigationTitle(L10n.Localizable.twofaStepsNavigationTitle)
        }
    }

    var mainView: some View {
        FeedbackView(title: L10n.Localizable.twofaEnforcementTitle,
                     message: L10n.Localizable.twofaEnforcementMessage1,
                     kind: .twoFA, hideBackButton: true,
                     primaryButton: (L10n.Localizable.twofaEnforcementSetupCta, { showSetupView = true  }),
                     secondaryButton: (L10n.Localizable.twofaEnforcementLogoutCta, model.logout),
                     accessory: {
            accessoryView
        })
        .fullScreenCover(isPresented: $showSetupView, onDismiss: {
            openAppStoreViewIfPossible()
            Task {
                await model.fetch()
                if model.isTwoFAEnabled {
                    dismiss()
                }
            }
        }, content: {
            TwoFASetupView(model: model.twoFASetupViewModelFactory.make(), appStoreViewer: $appStoreViewer, completion: {
                self.showSetupView = false
            })
        })
    }

    func openAppStoreViewIfPossible() {
                appStoreViewer?.openAppStorePage(dismissed: {})
        appStoreViewer = nil
    }

    var accessoryView: some View {
        Text(L10n.Localizable.twofaEnforcementMessage2)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(.ds.text.neutral.standard)
            .font(.body)
            .padding(.vertical, 32)
    }
}

 struct TwoFactorEnforcementView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            TwoFactorEnforcementView(model: .mock)
        }
    }

 }
