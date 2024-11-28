import Foundation
import SwiftUI
import UIDelight

#if canImport(UIKit)
  public struct RemoteLoginFlowView: View {

    @StateObject
    var viewModel: RemoteLoginFlowViewModel

    public init(viewModel: @autoclosure @escaping () -> RemoteLoginFlowViewModel) {
      self._viewModel = .init(wrappedValue: viewModel())
    }

    public var body: some View {
      switch viewModel.step {
      case let .login(type):
        switch type {
        case let .regularRemoteLogin(
          login,
          deviceRegistrationMethod,
          deviceInfo):
          RegularRemoteLoginFlow(
            viewModel: viewModel.makeRegularRemoteLoginFlowViewModel(
              login: login, deviceRegistrationMethod: deviceRegistrationMethod,
              deviceInfo: deviceInfo))
        case let .deviceToDeviceRemoteLogin(login, deviceInfo):
          DeviceTransferLoginFlow(
            model: viewModel.makeDeviceTransferLoginFlowModel(login: login, deviceInfo: deviceInfo))
        }
      case let .deviceUnlinking(unlinker, session, logInfo):
        DeviceUnlinkingFlow(
          viewModel: viewModel.makeDeviceUnlinkLoadingViewModel(
            deviceUnlinker: unlinker, session: session, logInfo: logInfo))
      }
    }
  }
#endif
