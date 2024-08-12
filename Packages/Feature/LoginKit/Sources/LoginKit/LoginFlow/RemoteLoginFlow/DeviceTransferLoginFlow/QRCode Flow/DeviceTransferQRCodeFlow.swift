import CoreLocalization
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import SwiftUI
import UIComponents
import UIDelight

#if canImport(UIKit)
  struct DeviceTransferQRCodeFlow: View {

    @Environment(\.dismiss)
    var dismiss

    @StateObject
    var model: DeviceTransferQRCodeFlowModel

    @Binding
    var progressState: ProgressionState

    public init(
      model: @autoclosure @escaping () -> DeviceTransferQRCodeFlowModel,
      progressState: Binding<ProgressionState>
    ) {
      self._model = .init(wrappedValue: model())
      self._progressState = progressState
    }

    var body: some View {
      navigationContent
        .animation(.default, value: model.isInProgress)
        .reportPageAppearance(.loginDeviceTransferQrCode)
    }

    var navigationContent: some View {
      StepBasedContentNavigationView(steps: $model.steps) { step in
        ZStack {
          switch step {
          case let .intro(state):
            DeviceTransferQrCodeView(
              model: model.makeDeviceToDeviceLoginQrCodeViewModel(state: state))
          case let .verifyLogin(loginData):
            DeviceTransferVerifyLoginView(login: loginData.login, progressState: $progressState) {
              result in
              Task {
                switch result {
                case .confirm:
                  await model.perform(.dataReceived(loginData))
                case .cancel:
                  await model.perform(.abortEvent)
                }
              }
            }
          }
          if model.isInProgress {
            ProgressionView(state: $progressState)
          }
        }
      }
    }
  }

  struct QRCodeLoginFlow_Previews: PreviewProvider {
    static var previews: some View {
      DeviceTransferQRCodeFlow(model: .mock, progressState: .constant(.inProgress("")))
    }
  }
#endif
