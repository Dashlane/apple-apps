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
        case let .unlock(secureLockMode, handler, type):
          LocalLoginUnlockView(
            viewModel: viewModel.makeLocalLoginUnlockViewModel(
              secureLockMode: secureLockMode,
              handler: handler,
              unlockType: type))
        case let .otp(option, hasLock):
          AccountVerificationFlow(
            model: viewModel.makeAccountVerificationFlowViewModel(
              method: .totp(option.pushType), hasLock: hasLock))
        case let .sso(info, deviceAccessKey):
          SSOLocalLoginView(
            model: viewModel.makeSSOLoginViewModel(
              ssoAuthenticationInfo: info, deviceAccessKey: deviceAccessKey))
        }
      }
    }
  }
#endif
