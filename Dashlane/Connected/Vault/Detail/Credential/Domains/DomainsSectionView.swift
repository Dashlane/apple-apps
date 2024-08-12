import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import VaultKit

struct DomainsSectionView: View {
  let sectionTitle: String
  let domains: [String]
  var isOpenable: Bool

  @Environment(\.openURL)
  var openURL

  var body: some View {
    if domains.count > 0 {
      Section(header: Text(sectionTitle.uppercased())) {
        ForEach(domains, id: \.self) { item in
          HStack {
            Text(item)
              .frame(maxWidth: .infinity, alignment: .leading)
            if let url = item.openableURL, isOpenable {
              Button {
                openURL(url)
              } label: {
                Image.ds.action.openExternalLink.outlined
              }

              .accessibilityLabel(CoreLocalization.L10n.Core.openWebsite)
            }
          }
        }
      }
    }
  }
}
