import CorePremium
import CoreUserTracking
import DesignSystem
import LoginKit
import SwiftUI
import UIDelight

struct ChangeMasterPasswordFlowView: View {

  @Environment(\.dismiss)
  private var dismiss

  @StateObject
  var viewModel: ChangeMasterPasswordFlowViewModel

  init(viewModel: @autoclosure @escaping () -> ChangeMasterPasswordFlowViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .intro:
        passwordChangerView
      case .updateMasterPassword:
        NewMasterPasswordView(model: viewModel.makeNewMasterPasswordViewModel(), title: "")
      case .passwordMigrationProgression:
        MigrationProgressView(model: viewModel.makeMigrationProgressViewModel())
          .navigationBarBackButtonHidden(true)
      }
    }
    .accentColor(.ds.text.brand.standard)
    .onReceive(viewModel.dismissPublisher) { _ in
      dismiss()
    }
    .reportPageAppearance(.settingsSecurityChangeMasterPassword)
  }

  @ViewBuilder
  private var passwordChangerView: some View {
    let isSyncEnabled = viewModel.isSyncEnabled
    let title =
      isSyncEnabled
      ? L10n.Localizable.changeMasterPasswordWarningPremiumTitle
      : L10n.Localizable.changeMasterPasswordWarningFreeDescription
    let subtitle =
      isSyncEnabled
      ? L10n.Localizable.changeMasterPasswordWarningPremiumDescription
      : L10n.Localizable.changeMasterPasswordWarningFreeTitle

    MasterPasswordMigrationView(
      title: title,
      subtitle: subtitle,
      migrateButtonTitle: L10n.Localizable.changeMasterPasswordWarningContinue,
      cancelButtonTitle: L10n.Localizable.changeMasterPasswordWarningCancel
    ) { result in
      switch result {
      case .cancel:
        viewModel.activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .cancel))
        dismiss()
      case .migrate:
        viewModel.activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .start))
        viewModel.updateMasterPassword()
      }
    }
  }
}
