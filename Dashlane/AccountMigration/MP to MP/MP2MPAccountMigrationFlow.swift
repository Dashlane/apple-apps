import LoginKit
import SwiftUI
import UIDelight

struct MP2MPAccountMigrationFlowView: View {

  @StateObject private var viewModel: MP2MPAccountMigrationViewModel

  init(viewModel: @autoclosure @escaping () -> MP2MPAccountMigrationViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    NavigationStack(path: .constant(viewModel.steps)) {
      Color.clear
        .navigationDestination(for: MP2MPAccountMigrationViewModel.Step.self) { step in
          switch step {
          case .confirmation:
            initialView
              .navigationBarBackButtonHidden()
          case .passwordInput:
            NewMasterPasswordView(model: viewModel.makeNewMasterPasswordViewModel(), title: "")
          case .migrationInProgress(let configuration):
            MigrationProgressView(
              model: viewModel.makeMigrationProgressViewModel(configuration: configuration)
            )
            .toolbar(.hidden, for: .navigationBar)
          }
        }
    }
  }

  @ViewBuilder
  private var initialView: some View {
    let isSyncAvailable = viewModel.isSyncAvailable

    let title =
      if isSyncAvailable {
        L10n.Localizable.changeMasterPasswordWarningPremiumTitle
      } else {
        L10n.Localizable.changeMasterPasswordWarningFreeTitle
      }

    let subtitle =
      if isSyncAvailable {
        L10n.Localizable.changeMasterPasswordWarningPremiumDescription
      } else {
        L10n.Localizable.changeMasterPasswordWarningFreeDescription
      }

    MasterPasswordMigrationView(
      title: title,
      subtitle: subtitle,
      migrateButtonTitle: L10n.Localizable.changeMasterPasswordWarningContinue,
      cancelButtonTitle: L10n.Localizable.changeMasterPasswordWarningCancel,
      completion: viewModel.makeInitialViewCompletion()
    )
  }
}
