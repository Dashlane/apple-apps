import AuthenticatorKit
import CoreLocalization
import CorePersonalData
import CoreSync
import DesignSystem
import Foundation
import LoginKit
import SwiftTreats
import SwiftUI
import TOTPGenerator
import UIDelight
import VaultKit

struct AddOTPFlowView: View {

  enum Result {
    case configuration(OTPConfiguration)
    case secret(String)
  }

  @Environment(\.dismiss)
  private var dismiss

  @StateObject
  private var viewModel: AddOTPFlowViewModel

  init(viewModel: @autoclosure @escaping () -> AddOTPFlowViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .intro:
        AddOTPIntroView(
          credential: viewModel.credential,
          completion: viewModel.introViewCompletionHandler)
      case .scanQRCode:
        #if os(visionOS)
          Text("Not Supported on VisionOS")
        #else
          ScanQRCodeView(resultHandler: qrCodeScanned)
        #endif
      case let .chooseCredential(viewModel):
        MatchingCredentialsListView(viewModel: viewModel)
      case let .success(mode):
        AddOTPSuccessView(
          mode: mode,
          action: {
            viewModel.handleSuccessCompletion(for: mode)
          })
      case .failure(.dashlaneSecretDetected):
        FeedbackView(
          title: CoreL10n.kwErrorTitle,
          message: CoreL10n.kwOtpDashlaneSecretRead,
          primaryButton: (
            CoreL10n.modalTryAgain, { viewModel.handleFailureViewCompletion(.tryAgain) }
          ),
          secondaryButton: (CoreL10n.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
      case let .failure(.badSecretKey(domain)):
        FeedbackView(
          title: L10n.Localizable._2faSetupFailureFor(domain),
          message: "",
          primaryButton: (
            CoreL10n.modalTryAgain, { viewModel.handleFailureViewCompletion(.tryAgain) }
          ),
          secondaryButton: (CoreL10n.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
      case let .failure(.multipleMatchingCredentials(domain)):
        FeedbackView(
          title: L10n.Localizable._2faSetupFailureFor(domain),
          message: L10n.Localizable.otpToolAddOtpErrorMultiloginTitle(domain),
          primaryButton: (CoreL10n.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
      case .failure(.badOTP):
        FeedbackView(
          title: L10n.Localizable._2faSetupFailureGeneric,
          message: "",
          primaryButton: (
            CoreL10n.modalTryAgain, { viewModel.handleFailureViewCompletion(.tryAgain) }
          ),
          secondaryButton: (CoreL10n.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
      case let .addCredential(credential):
        CredentialDetailView(model: viewModel.makeCredentialDetailViewModel(credential: credential))
      case let .addOTPManually(credential):
        AddOTPManuallyFlowView(
          viewModel: viewModel.makeAddOTPManuallyFlowViewModel(credential: credential))
      }
    }
    .tint(.ds.text.brand.standard)
    .onReceive(viewModel.dismissPublisher) { _ in
      dismiss()
    }
  }

  private func qrCodeScanned(result: Swift.Result<OTPConfiguration, Error>) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      viewModel.handleScanCompletion(result)
    }
  }
}

struct AddOTPFlowView_Previews: PreviewProvider {

  static var previews: some View {
    Group {
      Text("Preview")
    }
    .sheet(isPresented: .constant(true), onDismiss: nil) {
      AddOTPFlowView(viewModel: .mock)

    }
  }
}
