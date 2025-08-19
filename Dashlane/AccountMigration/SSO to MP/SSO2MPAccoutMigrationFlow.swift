import CoreLocalization
import LoginKit
import SwiftUI
import UIDelight

struct SSO2MPAccoutMigrationFlow: View {

  @StateObject private var viewModel: SSO2MPAccountMigrationViewModel

  init(viewModel: @escaping @autoclosure () -> SSO2MPAccountMigrationViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: .constant(viewModel.steps)) { step in
      switch step {
      case .confirmation:
        MasterPasswordMigrationView(
          title: L10n.Localizable.ssoToMPTitle,
          subtitle: L10n.Localizable.ssoToMPSubtitle,
          migrateButtonTitle: L10n.Localizable.ssoToMPButton,
          cancelButtonTitle: CoreL10n.kwLogOut,
          completion: viewModel.makeInitialViewCompletion()
        )
      case .ssoAuthentication(let ssoAuthenticationInfo):
        SSOView(model: viewModel.makeSSOViewModel(with: ssoAuthenticationInfo))
          .navigationBarVisible()
      case .masterPasswordCreation:
        NewMasterPasswordView(model: viewModel.makeNewMasterPasswordViewModel(), title: "")
          .navigationBarVisible()
      case .migrationInProgress(let configuration):
        MigrationProgressView(
          model: viewModel.makeMigrationProgressViewModel(configuration: configuration))
      }
    }
  }
}
