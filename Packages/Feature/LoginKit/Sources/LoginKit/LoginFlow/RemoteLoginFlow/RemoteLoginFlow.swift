#if canImport(UIKit)
import Foundation
import SwiftUI
import UIDelight
import CoreSession

public struct RemoteLoginFlow: View {
    @StateObject
    var viewModel: RemoteLoginFlowViewModel

    public init(viewModel: @autoclosure @escaping () -> RemoteLoginFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    public var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case let .token(tokenViewModel):
                TokenView(model: tokenViewModel)
            case let .authenticatorPush(authenticatorPushViewModel):
                AuthenticatorPushView(model: authenticatorPushViewModel)
            case let .otp(TOTPRemoteLoginViewModel):
                TOTPLoginView(model: TOTPRemoteLoginViewModel)
            case let .masterPassword(masterPasswordViewModel):
                MasterPasswordView(model: masterPasswordViewModel)
            case let .deviceUnlinking(deviceUnlinkingViewModel):
                DeviceUnlinkingFlow(viewModel: deviceUnlinkingViewModel)
            case let .sso(validator):
                if validator.isNitroProvider {
                    NitroSSOLoginView(model: viewModel.makeNitroSSOLoginViewModel(with: validator), clearCookies: true)
                } else {
                    SelfHostedSSOView(model: viewModel.makeSelfHostedSSOLoginViewModel(with: validator), clearCookies: true)
                }
            }
        }
    }
}
#endif
