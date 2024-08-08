#if canImport(UIKit)
  import SwiftUI
  import UIDelight
  import CoreSession
  import CoreLocalization
  import SwiftTreats
  import DashTypes

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
        DiagnosticMode.isEnabled ? error.localizedDescription : L10n.Core.deviceUnlinkAlertTitle
      return Alert(
        title: Text(L10n.Core.deviceUnlinkAlertTitle),
        message: Text(message),
        primaryButton: .cancel(
          Text(L10n.Core.cancel), action: { self.viewModel.completion(.logout) }),
        secondaryButton: .default(
          Text(L10n.Core.deviceUnlinkAlertTryAgain),
          action: { self.viewModel.retryAction(devices: devices) }))
    }

    private func alert(purchaseError error: Error) -> Alert {
      let message =
        DiagnosticMode.isEnabled
        ? error.localizedDescription : L10n.Core.planScreensPurchaseErrorMessage
      return Alert(
        title: Text(L10n.Core.planScreensPurchaseErrorTitle),
        message: Text(message),
        primaryButton: .cancel(
          Text(L10n.Core.cancel), action: { self.viewModel.completion(.logout) }),
        secondaryButton: .default(
          Text(L10n.Core.deviceUnlinkAlertTryAgain),
          action: { self.viewModel.showPurchasePlanFlow() }))
    }
  }
#endif
