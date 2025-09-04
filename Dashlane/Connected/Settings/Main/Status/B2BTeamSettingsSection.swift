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
            .foregroundStyle(color)
            .padding(.vertical, 3)
        }
        VStack(alignment: .leading, spacing: 3) {
          Text(L10n.Localizable.ActivePlan.dashlaneBusinessTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textStyle(.title.section.medium)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
          if let name = team.teamInfo.name {
            Text(name)
              .textStyle(.body.standard.regular)
              .foregroundStyle(Color.ds.text.neutral.quiet)
          }
        }
      }.padding(.vertical, 10)
    }
  }
}

struct B2BTeamSettingsSection_Previews: PreviewProvider {
  static var previews: some View {
    List {
      B2BTeamSettingsSection(team: .mock())
    }
    .listStyle(.ds.insetGrouped)
  }
}
