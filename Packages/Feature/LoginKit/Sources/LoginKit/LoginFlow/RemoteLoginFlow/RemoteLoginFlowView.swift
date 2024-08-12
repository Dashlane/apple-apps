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
      case let .remoteLogin(type):
        switch type {
        case let .classicRemoteLogin(handler):
          RegularRemoteLoginFlow(
            viewModel: viewModel.makeClassicRemoteLoginFlowViewModel(using: handler))
        case let .deviceToDeviceRemoteLogin(login, handler):
          DeviceTransferLoginFlow(
            model: viewModel.makeDeviceTransferLoginFlowModel(using: handler, login: login))
        }
      case let .deviceUnlinking(unlinker, session, logInfo, handler):
        DeviceUnlinkingFlow(
          viewModel: viewModel.makeDeviceUnlinkLoadingViewModel(
            deviceUnlinker: unlinker, session: session, logInfo: logInfo,
            remoteLoginHandler: handler))
      }
    }
  }
#endif
