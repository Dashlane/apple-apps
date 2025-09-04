import CoreTypes
import SwiftUI
import UIDelight

struct CredentialProviderFlow: View {
  @Environment(\.openURL)
  private var openURL

  @ObservedObject
  var model: CredentialProviderFlowModel

  var body: some View {
    StepBasedNavigationView(steps: $model.steps) { step in
      switch step {
      case .list:
        CredentialListView(model: model.makeCredentialListViewModel()) {
          model.steps.append(.addCredentialPassword)
        }
      case .frozen:
        Rectangle()
          .onAppear {
            openURL(URL(string: "dashlane:///getpremium?frozen=true")!)
          }
      case .addCredentialPassword:
        AddCredentialView(model: model.makeAddCredentialPasswordViewModel())
      }
    }
    .tint(.ds.accentColor)
    .modifier(AutofillConnectedEnvironmentViewModifier(model: model.environmentModelFactory.make()))
  }

}
