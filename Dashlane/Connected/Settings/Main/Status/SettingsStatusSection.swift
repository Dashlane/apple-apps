import CorePremium
import CoreTypes
import SwiftUI

struct SettingsStatusSection: View {
  @StateObject
  var model: SettingsStatusSectionViewModel

  @Environment(\.openURL) private var openURL

  init(model: @autoclosure @escaping () -> SettingsStatusSectionViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    if let b2bStatus = model.status.b2bStatus, b2bStatus.statusCode == .inTeam,
      let team = b2bStatus.currentTeam
    {
      B2BTeamSettingsSection(team: team)
    } else {
      ActivePlanSettingsSection(
        status: model.status.b2cStatus, vaultState: model.vaultState,
        showPurchase: model.showPurchase,
        learnMore: { openURL(DashlaneURLFactory.learnMoreAboutFrozenAccounts) })
    }
  }

}
