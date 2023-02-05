import SwiftUI
import CorePremium

struct SettingsStatusSection: View {
    @StateObject
    var model: SettingsStatusSectionViewModel

    init(model: @autoclosure @escaping () -> SettingsStatusSectionViewModel) {
        _model = .init(wrappedValue: model())
    }

    var body: some View {
        if let team = model.businessTeam {
            BusinessTeamSettingsSection(team: team)
        } else if let status = model.status {
            ActivePlanSettingsSection(status: status ) {
                model.showPurchase()
            }
        }
    }

}
