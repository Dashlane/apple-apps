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
        case let .masterPassword(_, method, deviceInfo):
          MasterPasswordRemoteLoginFlow(
            viewModel: viewModel.makeMasterPasswordRemoteLoginFlowModel(
              verificationMethod: method, deviceInfo: deviceInfo))
        case let .sso(info, deviceInfo):
          SSORemoteLoginView(
            model: viewModel.makeSSOLoginViewModel(
              ssoAuthenticationInfo: info, deviceInfo: deviceInfo))
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
