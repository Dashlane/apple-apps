import AutofillKit
import CoreLocalization
import CorePersonalData
import CoreUserTracking
import DesignSystem
import PremiumKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct CredentialProviderHomeFlow: View {

  enum SubFlows: Hashable {
    case addCredential
  }

  @ObservedObject
  var model: HomeFlowViewModel

  var body: some View {
    CredentialListView(model: model.makeCredentialListViewModel())
      .accentColor(.ds.text.brand.standard)
      .modifier(
        AutofillConnectedEnvironmentViewModifier(model: model.environmentModelFactory.make()))
  }

}
