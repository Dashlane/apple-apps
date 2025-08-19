import AuthenticatorKit
import CorePersonalData
import CoreSync
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import TOTPGenerator
import UIDelight
import VaultKit

struct AddOTPManuallyFlowView: View {

  @StateObject
  private var viewModel: AddOTPManuallyFlowViewModel

  init(viewModel: @autoclosure @escaping () -> AddOTPManuallyFlowViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .manuallyChooseWebsite:
        ChooseWebsiteView(viewModel: viewModel.makeChooseWebsiteViewModel())
      case let .enterLoginDetails(website, credential):
        AddLoginDetailsView(
          viewModel: viewModel.makeAddLoginDetailsViewModel(
            website: website,
            credential: credential))
      case let .chooseCredential(website, matchingCredentials):
        MatchingCredentialsListView(
          viewModel: viewModel.makeMatchingCredentialListViewModel(
            website: website, matchingCredentials: matchingCredentials))
      case let .enterToken(credential):
        AddOTPSecretKeyView(
          viewModel: viewModel.makeAddOTPSecretKeyViewModel(credential: credential))
      case let .success(mode, configuration):
        AddOTPSuccessView(
          mode: mode,
          action: {
            viewModel.handleSuccessCompletion(for: mode, configuration: configuration)
          })
      case let .addCredential(credential, configuration):
        CredentialDetailView(
          model: viewModel.makeCredentialDetailViewModel(
            credential: credential, configuration: configuration))
      }
    }
    .tint(.ds.text.brand.standard)
  }
}

struct AddOTPManuallyFlowView_Previews: PreviewProvider {

  static var previews: some View {
    Group {
      EmptyView()
    }
    .sheet(isPresented: .constant(true), onDismiss: nil) {
      AddOTPManuallyFlowView(viewModel: .mock)
    }
  }
}
