import SwiftUI
import UIDelight
import Combine
import DashTypes
import CoreUserTracking

struct AddItemFlowView: View {
    
    @StateObject
    var viewModel: AddItemFlowViewModel
    
    @Environment(\.dismiss)
    private var dismiss
    
    init(viewModel: @autoclosure @escaping () -> AddItemFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }
    
    var body: some View {
        navigationView
            .onReceive(viewModel.dismissPublisher) {
                dismiss()
            }
            .navigationBarStyle(.transparent)
    }
    
    var navigationView: some View {
        StepBasedNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case let .intro(hasAtLeastOneTokenStoredInVault):
                AddItemIntroView(hasAtLeastOneTokenStoredInVault: hasAtLeastOneTokenStoredInVault) { action in
                    switch action {
                    case .addToken:
                        viewModel.steps.append(.setupMethod)
                    case .showHelp:
                        viewModel.steps.append(.accountHelp)
                    }
                }
            case .accountHelp:
                SetupHelpView(image: AuthenticatorAsset.onboardingStep1, caption: L10n.Localizable.stepLabel("1"), title: L10n.Localizable.tokenAccountHelpTitle, helpTitle: L10n.Localizable.tokenAccountHelpCta, helpMessage: L10n.Localizable.tokenAccountHelpMessage, primaryButton: (title: L10n.Localizable.buttonTitleNext, action: {
                    viewModel.steps.append(.settingsHelp)
                }), secondaryButtonTitle: L10n.Localizable.tokenAccountHelpCta, skipAction: {
                    viewModel.steps.append(.setupMethod)
                })
            case .settingsHelp:
                SetupHelpView(image: AuthenticatorAsset.onboardingStep2, caption: L10n.Localizable.stepLabel("2"), title: L10n.Localizable.tokenSettingsHelpTitle, helpTitle: L10n.Localizable.tokenSettingsHelpCta, helpMessage: L10n.Localizable.tokenSettingsHelpMessage, primaryButton: (title: L10n.Localizable.buttonTitleNext, action: {
                    viewModel.steps.append(.codeHelp)
                }), secondaryButtonTitle: L10n.Localizable.tokenSettingsHelpCta, skipAction: {
                    viewModel.steps.append(.setupMethod)
                })
            case .codeHelp:
                SetupHelpView(image: AuthenticatorAsset.onboardingStep3, caption: L10n.Localizable.stepLabel("3"), title: L10n.Localizable.tokenCodesHelpTitle, helpTitle: L10n.Localizable.tokenCodesHelpCta, helpMessage: L10n.Localizable.tokenCodesHelpMessage, primaryButton: (title: L10n.Localizable.setupHelpAddTokenCta, action: {
                    viewModel.steps.append(.setupMethod)
                }), secondaryButtonTitle: L10n.Localizable.tokenCodesHelpCta, skipAction: {
                    viewModel.steps.append(.setupMethod)
                })
            case .setupMethod:
                AddTokenMethodSelectionView() { action in
                    switch action {
                    case .scanCode:
                        Task {
                            await self.viewModel.startScanCode()
                        }
                    case .enterCodeManually:
                        self.viewModel.startManuallyChooseWebsite()
                    }
                }
            case let .scanCode(viewModel):
                AddItemScanCodeFlowView(viewModel: viewModel)
            case let .enterCodeManually(viewModel):
                AddItemManuallyFlowView(viewModel: viewModel)
            }
        }
    }
}

struct AddItemRootView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthenticatorMockContainer().makeAddItemFlowViewModel(hasAtLeastOneTokenStoredInVault: true, mode: .standalone, completion: { _ in })
        AddItemFlowView(viewModel: viewModel)
    }
}
