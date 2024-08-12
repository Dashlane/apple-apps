import CorePremium
import SwiftUI
import UIComponents

struct B2BTeamSettingsSection: View {
  let team: CurrentTeam
  var body: some View {
    Section {
      HStack(alignment: .center, spacing: 10) {
        if let colorHex = team.teamInfo.color, let color = Color(hex: colorHex) {
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
          if let name = team.teamInfo.name {
            Text(name)
              .font(.subheadline.weight(.medium))
              .foregroundColor(.ds.text.neutral.quiet)
          }
        }
      }.padding(.vertical, 10)
    }
  }
}

struct B2BTeamSettingsSection_Previews: PreviewProvider {
  static var previews: some View {
    List {
      B2BTeamSettingsSection(team: .mock)
    }
    .listAppearance(.insetGrouped)
  }
}

extension CurrentTeam {
  fileprivate static var mock: CurrentTeam {
    return CurrentTeam(
      planName: "",
      nextBillingDateUnix: nil,
      isSoftDiscontinued: false,
      teamId: 1,
      planFeature: .business,
      joinDateUnix: 1,
      teamMembership: .init(
        teamAdmins: [], billingAdmins: [], isTeamAdmin: false, isBillingAdmin: false,
        isSSOUser: false, isGroupManager: false),
      teamInfo: .init(membersNumber: 1, planType: "", color: "d22", letter: "J", name: "J team")
    )
  }
}
