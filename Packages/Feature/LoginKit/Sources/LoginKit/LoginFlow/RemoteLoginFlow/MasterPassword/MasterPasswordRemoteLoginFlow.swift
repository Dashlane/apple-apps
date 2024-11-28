import Foundation
import SwiftUI
import UIDelight

struct MasterPasswordRemoteLoginFlow: View {

  @StateObject
  var viewModel: MasterPasswordRemoteLoginFlowModel

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case let .verification(method, deviceInfo):
        AccountVerificationFlow(
          model: viewModel.makeAccountVerificationFlowViewModel(
            method: method, deviceInfo: deviceInfo))
      case let .masterPassword(state, data):
        MasterPasswordInputRemoteView(
          model: viewModel.makeMasterPasswordInputRemoteViewModel(state: state, data: data))
      }
    }
  }
}

#Preview {
  MasterPasswordRemoteLoginFlow(viewModel: .mock)
}
