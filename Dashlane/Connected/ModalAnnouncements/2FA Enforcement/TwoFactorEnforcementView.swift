import Foundation
import SwiftUI
import UIDelight
import UIComponents
import DesignSystem
import CoreSession
import CoreNetworking

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
                     message: L10n.Localizable.twofaEnforcementMessage1 + "\n\n" + L10n.Localizable.twofaEnforcementMessage2,
                     kind: .twoFA, hideBackButton: true, primaryButton: (L10n.Localizable.twofaEnforcementSetupCta, { showSetupView = true  }), secondaryButton: (L10n.Localizable.twofaEnforcementLogoutCta, model.logout))
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
}

 struct TwoFactorEnforcementView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            TwoFactorEnforcementView(model: .mock)
        }
    }

 }
