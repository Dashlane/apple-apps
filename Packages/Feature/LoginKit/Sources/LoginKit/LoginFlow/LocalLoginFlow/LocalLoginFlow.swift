#if canImport(UIKit)
import Foundation
import SwiftUI
import UIDelight
import CoreSession

public struct LocalLoginFlow: View {
    @StateObject
    var viewModel: LocalLoginFlowViewModel

    public init(viewModel: @autoclosure @escaping () -> LocalLoginFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    public var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case let .unlock(viewModel):
                LocalLoginUnlockView(viewModel: viewModel)
            case let .otp(option, hasLock):
                AccountVerificationFlow(model: viewModel.makeAccountVerificationFlowViewModel(method: .totp(option.pushType), hasLock: hasLock))
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
