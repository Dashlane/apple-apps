import SwiftUI
import CorePremium
import UIComponents

struct BusinessTeamSettingsSection: View {
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
                        .foregroundColor(.ds.text.neutral.standard)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let name = team.space.teamName {
                        Text(name)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.ds.text.neutral.quiet)
                    }
                }
            }.padding(.vertical, 10)
        }
    }
}

struct BuinessTeamSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            BusinessTeamSettingsSection(team: .init(space: .mock, anonymousTeamId: ""))
        }.listStyle(.insetGrouped)
    }
}

private extension Space {
    static var mock: Space {
        Space(teamId: "id",
              teamName: "J team",
              letter: "J",
              color: "d22",
              associatedEmail: "",
              membersNumber: 1,
              teamAdmins: [],
              billingAdmins: [],
              isTeamAdmin: true,
              isBillingAdmin: true,
              planType: "",
              status: .accepted,
              info: SpaceInfo())
    }
}
