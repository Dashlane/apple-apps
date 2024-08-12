import AuthenticatorKit
import CorePersonalData
import CoreUserTracking
import DesignSystem
import Foundation
import IconLibrary
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct AuthenticatorToolFlowView: View {

  @StateObject
  private var viewModel: AuthenticatorToolFlowViewModel

  init(viewModel: @autoclosure @escaping () -> AuthenticatorToolFlowViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .explorer(isFirstView: true):
        OTPExplorerView(viewModel: viewModel.makeExplorerViewModel())
          .reportPageAppearance(.toolsAuthenticatorWelcome)
      case .explorer:
        OTPExplorerView(viewModel: viewModel.makeExplorerViewModel())
          .reportPageAppearance(.toolsAuthenticatorExplore)
      case .otpList:
        OTPTokenListView(
          viewModel: viewModel.makeTokenListViewModel(), expandedToken: $viewModel.expandedToken
        )
        .reportPageAppearance(.toolsAuthenticatorLogins)
      }
    }
    .accentColor(.ds.text.brand.standard)
    .fullScreenCover(isPresented: $viewModel.presentAdd2FAFlow) {
      AddOTPFlowView(viewModel: viewModel.makeAddOTPFlowViewModel())
    }
  }
}
