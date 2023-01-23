import Foundation
import SwiftUI
import UIDelight

struct AddItemManuallyFlowView: View {
    
    @StateObject
    var viewModel: AddItemManuallyFlowViewModel
    
    init(viewModel: @autoclosure @escaping () -> AddItemManuallyFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }
    
    var body: some View {
        navigationView
    }
    
    var navigationView: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case let .manuallyChooseWebsite(viewModel):
                ChooseWebsiteView(viewModel: viewModel)
            case let .credentialsMatchingWebsite(viewModel):
                MatchingCredentialsListView(viewModel: viewModel)
            case let .addLoginDetailsForm(viewModel):
                AddLoginDetailsView(viewModel: viewModel)
            case let .failedToAddItem(website):
                failedToAddItemErrorView(website: website)
            case let .preview(model, completion):
                AddItemPreviewView(model: model, isFirstToken: viewModel.isFirstToken, completion: completion)
            case let .scanCode(viewModel):
                AddItemScanCodeFlowView(viewModel: viewModel)
            case let .dashlane2FAMessage(otpInfo):
                Dashlane2FAMessageView() {
                    viewModel.complete(otpInfo, mode: .textCode)
                }
            }
        }
    }
    
    func failedToAddItemErrorView(website: String) -> some View {
        FeedbackView(title: L10n.Localizable.errorAdd2FaTitle(website),
                  message: L10n.Localizable.errorAdd2FaMessage(L10n.Localizable.errorAdd2FaMessageModeManual, L10n.Localizable.errorAdd2FaMessageModeManualTryScan),
                  primaryButton: (L10n.Localizable.errorAdd2FaTryAgain, {
            viewModel.resetFlow()
        }),
                  secondaryButton: (L10n.Localizable.addOtpFlowScanCodeCta, {
            viewModel.startScanCodeFlow()
        }))
    }
}

struct AddItemManuallyFlowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthenticatorMockContainer().makeAddItemFlowViewModel(hasAtLeastOneTokenStoredInVault: true, mode: .standalone, completion: { _ in })
        AddItemFlowView(viewModel: viewModel)
    }
}
