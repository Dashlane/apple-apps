import CoreLocalization
import CoreSession
import DashTypes
import DesignSystem
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
          .toolbar {
            ToolbarItem(
              placement: .topBarLeading,
              content: {
                BackButton(
                  label: L10n.Core.kwBack,
                  action: {
                    Task {
                      await model.perform(.cancel)
                    }
                  })
              })
          }
        case let .securityChallenge(login):
          DeviceTransferSecurityChallengeFlow(
            model: model.makeSecurityChallengeFlowModel(login: login)
          ).navigationBarBackButtonHidden()
            .toolbar {
              ToolbarItem(
                placement: .topBarLeading,
                content: {
                  BackButton(
                    label: L10n.Core.kwBack,
                    action: {
                      Task {
                        await model.perform(.cancel)
                      }
                    })
                })
            }
        case let .qrcode(login, state):
          DeviceTransferQRCodeFlow(
            model: model.makeDeviceToDeviceQRCodeLoginFlowModel(login: login, state: state),
            progressState: $model.progressState
          )
          .navigationBarBackButtonHidden()
          .toolbar {
            ToolbarItem(
              placement: .topBarLeading,
              content: {
                BackButton(
                  label: L10n.Core.kwBack,
                  action: {
                    Task {
                      await model.perform(.cancel)
                    }
                  })
              })
          }
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
        case let .recoveryFlow(info, deviceInfo):
          DeviceTransferRecoveryFlow(
            model: model.makeAccountRecoveryFlowModel(info: info, deviceInfo: deviceInfo))
        }
        if model.isInProgress {
          ProgressionView(state: $model.progressState)
            .navigationBarBackButtonHidden()
        }
      }
    }.animation(.default, value: model.isInProgress)
      .fullScreenCover(item: $model.error) { error in
        errorView(for: error)
      }
  }

  func errorView(for error: TransferError) -> some View {
    switch error {
    case .unknown:
      return FeedbackView(
        title: L10n.Core.Mpless.D2d.Untrusted.genericErrorTitle,
        message: L10n.Core.Mpless.D2d.Untrusted.genericErrorMessage,
        primaryButton: (
          L10n.Core.Mpless.D2d.Untrusted.genericErrorCta,
          {
            Task {
              await model.perform(.cancel)
            }
          }
        ),
        secondaryButton: (
          L10n.Core.Mpless.D2d.Untrusted.genericErrorSupportCta,
          {
            UIApplication.shared.open(DashlaneURLFactory.request)
          }
        ))
    case .timeout:
      return FeedbackView(
        title: L10n.Core.Mpless.D2d.Untrusted.timeoutErrorTitle,
        message: L10n.Core.Mpless.D2d.Untrusted.timeoutErrorMessage,
        primaryButton: (
          L10n.Core.Mpless.D2d.Untrusted.timeoutErrorCta,
          {
            Task {
              await model.perform(.cancel)
            }
          }
        ))
    }
  }
}
