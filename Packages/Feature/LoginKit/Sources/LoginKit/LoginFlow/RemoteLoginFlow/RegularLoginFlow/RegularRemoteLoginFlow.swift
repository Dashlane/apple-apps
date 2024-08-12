#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import UIDelight
  import CoreSession

  public struct RegularRemoteLoginFlow: View {
    @StateObject
    var viewModel: RegularRemoteLoginFlowViewModel

    public init(viewModel: @autoclosure @escaping () -> RegularRemoteLoginFlowViewModel) {
      self._viewModel = .init(wrappedValue: viewModel())
    }

    public var body: some View {
      StepBasedContentNavigationView(steps: $viewModel.steps) { step in
        switch step {
        case let .verification(method):
          AccountVerificationFlow(
            model: viewModel.makeAccountVerificationFlowViewModel(method: method))
        case let .masterPassword(loginKeys):
          MasterPasswordRemoteView(
            model: viewModel.makeMasterPasswordViewModel(loginKeys: loginKeys))
        case let .sso(info):
          SSORemoteLoginView(model: viewModel.makeSSOLoginViewModel(ssoAuthenticationInfo: info))
        }
      }
    }
  }

  struct RegularRemoteLoginFlow_Previews: PreviewProvider {
    static var previews: some View {
      RegularRemoteLoginFlow(viewModel: RegularRemoteLoginFlowViewModel.mock())
    }
  }
#endif
