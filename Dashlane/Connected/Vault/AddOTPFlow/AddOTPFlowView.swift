import Foundation
import SwiftTreats
import SwiftUI
import UIDelight
import TOTPGenerator
import CoreSync
import CorePersonalData
import VaultKit
import DesignSystem

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
                AddOTPIntroView(credential: viewModel.credential,
                                completion: viewModel.introViewCompletionHandler)
            case let .enterToken(viewModel):
                AddOTPSecretKeyView(viewModel: viewModel)
            case .scanQRCode:
                ScanQRCodeView(resultHandler: qrCodeScanned)
            case let .chooseCredential(viewModel):
                MatchingCredentialsListView(viewModel: viewModel)
            case let .success(mode):
                AddOTPSuccessView(mode: mode, action: {
                    viewModel.handleSuccessCompletion(for: mode)
                })
            case .failure(.dashlaneSecretDetected):
                FeedbackView(title: L10n.Localizable.kwErrorTitle,
                             message: L10n.Localizable.kwOtpDashlaneSecretRead,
                             primaryButton: (L10n.Localizable.modalTryAgain, { viewModel.handleFailureViewCompletion(.tryAgain) }),
                             secondaryButton: (L10n.Localizable.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
            case let .failure(.badSecretKey(domain)):
                FeedbackView(title: L10n.Localizable._2faSetupFailureFor(domain),
                             message: "",
                             primaryButton: (L10n.Localizable.modalTryAgain, { viewModel.handleFailureViewCompletion(.tryAgain) }),
                             secondaryButton: (L10n.Localizable.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
            case  let .failure(.multipleMatchingCredentials(domain)):
                FeedbackView(title: L10n.Localizable._2faSetupFailureFor(domain),
                             message: L10n.Localizable.otpToolAddOtpErrorMultiloginTitle(domain),
                             primaryButton: (L10n.Localizable.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
            case let .addCredential(viewModel):
                CredentialDetailView(model: viewModel).navigationBarHidden(true)
            }
        }
        .accentColor(.ds.text.brand.standard)
        .onReceive(viewModel.dismissPublisher) { _ in
            dismiss()
        }
    }

    private func qrCodeScanned(configuration: OTPConfiguration) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.handleScanCompletion(configuration)
        }
    }
}

struct AddOTPFlowView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            EmptyView()
        }
        .sheet(isPresented: .constant(true), onDismiss: nil) {
            AddOTPFlowView(viewModel: .mock)

        }
    }
}
