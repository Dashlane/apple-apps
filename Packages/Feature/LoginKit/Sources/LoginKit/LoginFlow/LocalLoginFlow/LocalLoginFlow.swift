import CoreSession
import Foundation
import SwiftUI
import UIDelight

public struct LocalLoginFlow: View {
  @StateObject
  var viewModel: LocalLoginFlowViewModel

  public init(viewModel: @autoclosure @escaping () -> LocalLoginFlowViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  public var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case let .unlock(unlockInfo):
        LocalLoginUnlockView(
          viewModel: viewModel.makeLocalLoginUnlockViewModel(userUnlockInfo: unlockInfo))
      case let .otp(option, lockType, deviceInfo):
        AccountVerificationFlow(
          model: viewModel.makeAccountVerificationFlowViewModel(
            method: .totp(option.pushType), lockType: lockType, deviceInfo: deviceInfo))
      case let .sso(initialState, info, deviceAccessKey):
        SSOLocalLoginView(
          model: viewModel.makeSSOLoginViewModel(
            initialState: initialState, ssoAuthenticationInfo: info,
            deviceAccessKey: deviceAccessKey))
      }
    }
  }
}
