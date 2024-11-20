import AutofillKit
import CoreLocalization
import CorePersonalData
import CoreUserTracking
import DashTypes
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

  @Environment(\.openURL) private var openURL

  @ObservedObject
  var model: HomeFlowViewModel

  var body: some View {
    switch model.vaultState {
    case .default:
      CredentialListView(model: model.makeCredentialListViewModel())
        .accentColor(.ds.text.brand.standard)
        .modifier(
          AutofillConnectedEnvironmentViewModifier(model: model.environmentModelFactory.make())
        )
        .onAppear {
          model.onAppear()
        }
    case .frozen:
      Rectangle()
        .onAppear {
          openURL(URLScheme.dashlane.url)
        }
    }
  }

}
