import Foundation
import SwiftUI
import UIDelight

#if canImport(UIKit)
struct RemoteLoginFlowView: View {

    @StateObject
    var viewModel: RemoteLoginFlowViewModel

    public init(viewModel: @autoclosure @escaping () -> RemoteLoginFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case let .remoteLogin(type):
                switch type {
                case let .classicRemoteLogin(handler):
                    RegularRemoteLoginFlow(viewModel: viewModel.makeClassicRemoteLoginFlowViewModel(using: handler))
                case let .deviceToDeviceRemoteLogin(handler):
                    DeviceToDeviceLoginFlow(model: viewModel.makeDeviceToDeviceLoginFlowViewModel(using: handler))
                }
            case let .deviceUnlinking(unlinker, session, logInfo, handler):
                DeviceUnlinkingFlow(viewModel: viewModel.makeDeviceUnlinkLoadingViewModel(deviceUnlinker: unlinker, session: session, logInfo: logInfo, remoteLoginHandler: handler))
            }
        }
    }
}
#endif
