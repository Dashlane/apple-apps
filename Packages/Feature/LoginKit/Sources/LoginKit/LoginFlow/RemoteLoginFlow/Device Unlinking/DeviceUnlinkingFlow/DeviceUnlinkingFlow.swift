import CoreLocalization
import CoreSession
import CoreTypes
import LogFoundation
import SwiftTreats
import SwiftUI
import UIDelight

public struct DeviceUnlinkingFlow: View {
  @StateObject
  var viewModel: DeviceUnlinkingFlowViewModel

  public init(viewModel: @autoclosure @escaping () -> DeviceUnlinkingFlowViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  public var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case let .initial(mode, action):
        LimitedNumberOfDeviceView(mode: mode, action: action)
      case let .monobucketUnlink(device, action):
        MonobucketUnlinkView(device: device, action: action)
      case let .multiDevice(limit, devices, action):
        UnlinkMutltiDevicesView(
          limit: limit,
          devices: devices,
          action: action)
      case let .purchasePlanFlow(flow):
        flow
          .navigationBarBackButtonHidden(true)
      case let .loading(mode):
        DeviceUnlinkLoadingView(viewModel: viewModel.makeDeviceUnlinkLoadingViewModel(mode: mode))
          .alert(using: $viewModel.alert) { alert in
            switch alert {
            case let .unlinkFailed(devices, error):
              return self.alert(devices: devices, error: error)
            case let .purchaseFailed(error):
              return self.alert(purchaseError: error)
            }
          }
          .onReceive(viewModel.actionPublisher) { action in
            switch action {
            case let .finish(onComplete):
              onComplete()
            }
          }
      }
    }
  }

  private func alert(devices: Set<DeviceListEntry>, error: Error) -> Alert {
    let message =
      DiagnosticMode.isEnabled ? error.localizedDescription : CoreL10n.deviceUnlinkAlertTitle
    return Alert(
      title: Text(CoreL10n.deviceUnlinkAlertTitle),
      message: Text(message),
      primaryButton: .cancel(Text(CoreL10n.cancel), action: { self.viewModel.completion(.logout) }),
      secondaryButton: .default(
        Text(CoreL10n.deviceUnlinkAlertTryAgain),
        action: { self.viewModel.retryAction(devices: devices) }))
  }

  private func alert(purchaseError error: Error) -> Alert {
    let message =
      DiagnosticMode.isEnabled
      ? error.localizedDescription : CoreL10n.planScreensPurchaseErrorMessage
    return Alert(
      title: Text(CoreL10n.planScreensPurchaseErrorTitle),
      message: Text(message),
      primaryButton: .cancel(Text(CoreL10n.cancel), action: { self.viewModel.completion(.logout) }),
      secondaryButton: .default(
        Text(CoreL10n.deviceUnlinkAlertTryAgain), action: { self.viewModel.showPurchasePlanFlow() })
    )
  }
}
