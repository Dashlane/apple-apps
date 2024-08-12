import AuthenticatorKit
import Foundation
import LoginKit
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
      case .manuallyChooseWebsite:
        ChooseWebsiteView(viewModel: viewModel.makeChooseWebsiteViewModel())
      case let .credentialsMatchingWebsite(website, credentials):
        MatchingCredentialsListView(
          viewModel: viewModel.makeMatchingCredentialListViewModel(
            website: website, matchingCredentials: credentials))
      case let .addLoginDetailsForm(website, credential):
        AddLoginDetailsView(
          viewModel: viewModel.makeAddLoginDetailsViewModel(
            website: website, credential: credential))
      case let .failedToAddItem(website):
        failedToAddItemErrorView(website: website)
      case let .preview(otpInfo, completion):
        AddItemPreviewView(
          model: viewModel.makeTokeRowViewModel(otpInfo: otpInfo),
          isFirstToken: viewModel.isFirstToken, completion: completion)
      case .scanCode:
        AddItemScanCodeFlowView(viewModel: viewModel.makeAddItemScanCodeFlowViewModel())
      case let .dashlane2FAMessage(otpInfo):
        Dashlane2FAMessageView {
          viewModel.complete(otpInfo, mode: .textCode)
        }
      }
    }
  }

  func failedToAddItemErrorView(website: String) -> some View {
    FeedbackView(
      title: L10n.Localizable.errorAdd2FaTitle(website),
      message: L10n.Localizable.errorAdd2FaMessage(
        L10n.Localizable.errorAdd2FaMessageModeManual,
        L10n.Localizable.errorAdd2FaMessageModeManualTryScan),
      primaryButton: (
        L10n.Localizable.errorAdd2FaTryAgain,
        {
          viewModel.resetFlow()
        }
      ),
      secondaryButton: (
        L10n.Localizable.addOtpFlowScanCodeCta,
        {
          viewModel.startScanCodeFlow()
        }
      ))
  }
}

struct AddItemManuallyFlowView_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel = AuthenticatorMockContainer().makeAddItemFlowViewModel(
      hasAtLeastOneTokenStoredInVault: true, mode: .standalone, completion: { _ in })
    AddItemFlowView(viewModel: viewModel)
  }
}
