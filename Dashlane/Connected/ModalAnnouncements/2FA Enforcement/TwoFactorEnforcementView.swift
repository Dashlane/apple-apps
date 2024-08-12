import CoreNetworking
import CoreSession
import DesignSystem
import Foundation
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct TwoFactorEnforcementView: View {

  @Environment(\.dismiss) var dismiss

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
    FeedbackView(
      title: L10n.Localizable.twofaEnforcementTitle,
      message: L10n.Localizable.twoFactorEnforcementBody,
      kind: .twoFA, hideBackButton: true,
      primaryButton: (L10n.Localizable.twofaEnforcementLogoutCta, model.logout))
  }
}

struct TwoFactorEnforcementView_Previews: PreviewProvider {

  static var previews: some View {
    Group {
      TwoFactorEnforcementView(model: .mock)
    }
  }

}
