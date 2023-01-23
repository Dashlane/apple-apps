import SwiftUI
import CorePremium
import UIComponents

struct BuinessTeamSettingsSection: View {
    let team: BusinessTeam
    var body: some View {
        Section {
            HStack(alignment: .center, spacing: 10) {
                if let color = Color(hex: team.space.color) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 5)
                        .frame(maxHeight: .infinity)
                        .foregroundColor(color)
                        .padding(.vertical, 3)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.Localizable.ActivePlan.dashlaneBusinessTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let name = team.space.teamName {
                        Text(name)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color(asset: FiberAsset.secondaryText))
                    }
                }
            }.padding(.vertical, 10)
        }
    }
}

struct BuinessTeamSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            BuinessTeamSettingsSection(team: .init(space: TeamSpaceView_Previews.bussinessSpace, anonymousTeamId: ""))
        }.listStyle(.insetGrouped)
    }
}
