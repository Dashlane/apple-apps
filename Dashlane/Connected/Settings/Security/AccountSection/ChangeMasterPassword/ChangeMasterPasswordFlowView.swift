import SwiftUI
import UIDelight
import CoreUserTracking

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
            case .updateMasterPassword(let viewModel):
                NewMasterPasswordView(model: viewModel, title: "")
            case .passwordMigrationProgression(let viewModel):
                MigrationProgressView(model: viewModel)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .accentColor(Color(asset: FiberAsset.dashGreen))
        .onReceive(viewModel.dismissPublisher) { _ in
            dismiss()
        }
        .reportPageAppearance(.settingsSecurityChangeMasterPassword)
    }

    @ViewBuilder
    private var passwordChangerView: some View {
        let isSyncEnabled = viewModel.premiumService.capability(for: \.sync).enabled
        let title = isSyncEnabled ? L10n.Localizable.changeMasterPasswordWarningPremiumTitle : L10n.Localizable.changeMasterPasswordWarningFreeDescription
        let subtitle = isSyncEnabled ? L10n.Localizable.changeMasterPasswordWarningPremiumDescription : L10n.Localizable.changeMasterPasswordWarningFreeTitle

        MasterPasswordMigrationView(title: title,
                                    subtitle: subtitle,
                                    migrateButtonTitle: L10n.Localizable.changeMasterPasswordWarningContinue,
                                    cancelButtonTitle: L10n.Localizable.changeMasterPasswordWarningCancel) { result in
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
