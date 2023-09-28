import Foundation
import SwiftTreats
import SwiftUI
import UIDelight
import TOTPGenerator
import CoreSync
import CorePersonalData
import VaultKit
import AuthenticatorKit
import DesignSystem
import LoginKit
import CoreLocalization

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
            case .scanQRCode:
                ScanQRCodeView(resultHandler: qrCodeScanned)
            case let .chooseCredential(viewModel):
                MatchingCredentialsListView(viewModel: viewModel)
            case let .success(mode):
                AddOTPSuccessView(mode: mode, action: {
                    viewModel.handleSuccessCompletion(for: mode)
                })
            case .failure(.dashlaneSecretDetected):
                FeedbackView(title: CoreLocalization.L10n.Core.kwErrorTitle,
                             message: CoreLocalization.L10n.Core.kwOtpDashlaneSecretRead,
                             primaryButton: (CoreLocalization.L10n.Core.modalTryAgain, { viewModel.handleFailureViewCompletion(.tryAgain) }),
                             secondaryButton: (CoreLocalization.L10n.Core.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
            case let .failure(.badSecretKey(domain)):
                FeedbackView(title: L10n.Localizable._2faSetupFailureFor(domain),
                             message: "",
                             primaryButton: (CoreLocalization.L10n.Core.modalTryAgain, { viewModel.handleFailureViewCompletion(.tryAgain) }),
                             secondaryButton: (CoreLocalization.L10n.Core.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
            case  let .failure(.multipleMatchingCredentials(domain)):
                FeedbackView(title: L10n.Localizable._2faSetupFailureFor(domain),
                             message: L10n.Localizable.otpToolAddOtpErrorMultiloginTitle(domain),
                             primaryButton: (CoreLocalization.L10n.Core.cancel, { viewModel.handleFailureViewCompletion(.cancel) }))
            case let .addCredential(viewModel):
                CredentialDetailView(model: viewModel).navigationBarHidden(true)
            case let .addOTPManually(viewModel):
                AddOTPManuallyFlowView(viewModel: viewModel)
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
