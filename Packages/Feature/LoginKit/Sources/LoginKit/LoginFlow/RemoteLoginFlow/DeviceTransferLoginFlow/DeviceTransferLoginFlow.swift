import CoreLocalization
import CoreSession
import CoreTypes
import DesignSystem
import DesignSystemExtra
import Foundation
import SwiftUI
import UIComponents
import UIDelight

public struct DeviceTransferLoginFlow: View {

  @StateObject
  var model: DeviceTransferLoginFlowModel

  init(model: @escaping @autoclosure () -> DeviceTransferLoginFlowModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    StepBasedContentNavigationView(steps: $model.steps) { step in
      ZStack {
        switch step {
        case let .transferType(login):
          DeviceTransferTypeSelectionView(login: login) { event in
            Task {
              await model.deviceTransferTypeSelected(event: event)
            }
          }
          .navigationBarBackButtonHidden()
          .toolbar(content: cancelToolbar)

        case let .securityChallenge(login):
          DeviceTransferSecurityChallengeFlow(
            model: model.makeSecurityChallengeFlowModel(login: login)
          )
          .navigationBarBackButtonHidden()
          .toolbar(content: cancelToolbar)
        case let .qrcode(login, state):
          DeviceTransferQRCodeFlow(
            model: model.makeDeviceToDeviceQRCodeLoginFlowModel(login: login, state: state),
            progressState: $model.progressState
          )
          .navigationBarBackButtonHidden()
          .toolbar(content: cancelToolbar)

        case let .otp(initialState, option, data):
          DeviceTransferOTPLoginView(
            viewModel: model.makeDeviceToDeviceOTPLoginViewModel(
              initialState: initialState, option: option, data: data),
            progressState: $model.progressState)
        case let .pin(registerData):
          PinCodeSetupView(model: model.makePinCodeSetupViewModel(registerData: registerData))
        case let .biometry(biometry, registerData):
          BiometricQuickSetupView(biometry: biometry) { result in
            switch result {
            case .useBiometry:
              model.enableBiometry(with: registerData)
            case .skip:
              model.skipBiometry(with: registerData)
            }
          }
        case let .recoveryFlow(info):
          DeviceTransferRecoveryFlow(model: model.makeAccountRecoveryFlowModel(info: info))
        }
        if model.isInProgress {
          LottieProgressionFeedbacksView(state: model.progressState)
            .navigationBarBackButtonHidden()
        }
      }

    }.animation(.default, value: model.isInProgress)
      .fullScreenCover(item: $model.error) { error in
        errorView(for: error)
      }
  }

  private func cancelToolbar() -> some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      NativeNavigationBarBackButton(CoreL10n.kwBack, action: cancel)
    }
  }

  private func cancel() {
    Task {
      await model.perform(.cancel)
    }
  }

  func errorView(for error: TransferError) -> some View {
    switch error {
    case .unknown:
      return FeedbackView(
        title: CoreL10n.Mpless.D2d.Untrusted.genericErrorTitle,
        message: CoreL10n.Mpless.D2d.Untrusted.genericErrorMessage,
        primaryButton: (
          CoreL10n.Mpless.D2d.Untrusted.genericErrorCta,
          {
            Task {
              await model.perform(.cancel)
            }
          }
        ),
        secondaryButton: (
          CoreL10n.Mpless.D2d.Untrusted.genericErrorSupportCta,
          {
            UIApplication.shared.open(DashlaneURLFactory.request)
          }
        ))
    case .timeout:
      return FeedbackView(
        title: CoreL10n.Mpless.D2d.Untrusted.timeoutErrorTitle,
        message: CoreL10n.Mpless.D2d.Untrusted.timeoutErrorMessage,
        primaryButton: (
          CoreL10n.Mpless.D2d.Untrusted.timeoutErrorCta,
          {
            Task {
              await model.perform(.cancel)
            }
          }
        ))
    }
  }
}
