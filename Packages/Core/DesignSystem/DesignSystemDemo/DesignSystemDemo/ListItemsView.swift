import DesignSystem
import SwiftUI

struct ListItemsView: View {
  enum ViewConfiguration: String, CaseIterable {
    case lightAppearance
    case darkAppearance
    case smallestDynamicTypeSize
    case accessibilityDynamicTypeSize
  }

  var viewConfiguration: ViewConfiguration? {
    guard let configuration = ProcessInfo.processInfo.environment["listItemsConfiguration"]
    else { return nil }
    return ViewConfiguration(rawValue: configuration)
  }

  var body: some View {
    switch viewConfiguration {
    case .lightAppearance:
      commonView
        .preferredColorScheme(.light)
    case .darkAppearance:
      commonView
        .preferredColorScheme(.dark)
    case .smallestDynamicTypeSize:
      commonView
        .dynamicTypeSize(.xSmall)
    case .accessibilityDynamicTypeSize:
      commonView
        .dynamicTypeSize(.accessibility2)
    case .none:
      EmptyView()
    }
  }

  private var commonView: some View {
    List {
      ListItem(title: "Picard", description: "_", badge: "New") {
        DS.Thumbnail.User.group
          .controlSize(.small)
      }
      .highlightedValue("p")

      ListItem {
        ListItemLabel("AirJapan", description: "美穂先生＠provider.com", badge: "Updated") {
          Image.ds.arrowUp.outlined
            .resizable()
          Image.ds.arrowDown.outlined
            .resizable()
        }
      } leadingAccessory: {
        DS.Thumbnail.User.group
          .controlSize(.small)
      }
      .highlightedValue("先生")

      ListItem(title: "Uniqlo", description: "_", badge: "Badge") {
        DS.Thumbnail.User.group
          .controlSize(.small)
      } actions: {
        FieldAction.Menu("More", image: .ds.action.more.outlined) {}
        FieldAction.CopyContent {}
      }
      .highlightedValue("qlo")

      ListItem {
        ListItemLabel("My Credit Card") {
          ListItemCreditCardLabelDescription(
            icon: .ds.item.payment.outlined,
            number: "5425233430109903",
            expirationDate: Date(timeIntervalSince1970: 0)
          )
        }
      } leadingAccessory: {
        DS.Thumbnail.User.single(nil)
          .controlSize(.small)
      }

      ListItem(title: "Jean Dupont", description: "") {
        Thumbnail.User.single(nil)
          .controlSize(.mini)
      }
    }
    .tint(.ds.text.brand.standard)
  }
}

#Preview {
  ListItemsView()
}
