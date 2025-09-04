import SwiftUI

public struct ListItem<Content: View, Actions: View>: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.container) var container

  private let content: Content
  private let actions: Actions

  private var listRowInsets: EdgeInsets? {
    return switch container {
    case .list(.insetGrouped):
      EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
    case .list(.plain):
      EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8)
    case .root:
      nil
    }
  }

  public init(
    @ViewBuilder content: () -> Content,
    @ViewBuilder actions: () -> Actions
  ) {
    self.actions = actions()
    self.content = content()
  }

  public init<Label: View, LeadingAccessory: View>(
    @ViewBuilder label: () -> Label,
    @ViewBuilder leadingAccessory: () -> LeadingAccessory,
    @ViewBuilder actions: () -> Actions
  ) where Content == ListItemContentView<Label, LeadingAccessory> {
    self.content = ListItemContentView(label: label, leadingAccessory: leadingAccessory)
    self.actions = actions()
  }

  public init<Label: View, LeadingAccessory: View>(
    @ViewBuilder label: () -> Label,
    @ViewBuilder leadingAccessory: () -> LeadingAccessory
  ) where Content == ListItemContentView<Label, LeadingAccessory>, Actions == EmptyView {
    self.init(
      label: label,
      leadingAccessory: leadingAccessory,
      actions: { EmptyView() }
    )
  }

  public init<LeadingAccessory: View>(
    title: String,
    description: String,
    badge: String? = nil,
    @ViewBuilder leadingAccessory: () -> LeadingAccessory,
    @ViewBuilder actions: () -> Actions
  ) where Content == ListItemContentView<IconlessListItemLabel, LeadingAccessory> {
    self.init(
      label: {
        ListItemLabel(
          title,
          description: description,
          badge: badge
        )
      },
      leadingAccessory: leadingAccessory,
      actions: actions
    )
  }

  public init<LeadingAccessory: View>(
    title: String,
    description: String,
    badge: String? = nil,
    @ViewBuilder leadingAccessory: () -> LeadingAccessory
  )
  where
    Content == ListItemContentView<IconlessListItemLabel, LeadingAccessory>, Actions == EmptyView
  {
    self.init(
      title: title,
      description: description,
      badge: badge,
      leadingAccessory: leadingAccessory
    ) {
      EmptyView()
    }
  }

  public var body: some View {
    HStack(spacing: 0) {
      content
      FieldActionsStack(maxItemsNumber: 2, allowOverflowStacking: false) {
        actions
      }
    }
    .frame(minHeight: 40)
    .padding(.vertical, 8)
    .listRowInsets(listRowInsets)
    .transformEnvironment(\.dynamicTypeSize) { typeSize in
      guard dynamicTypeSize > .accessibility2 else { return }
      typeSize = .accessibility2
    }
  }

}

private struct PreviewContent: View {
  @ScaledMetric private var imageDimension = 12
  @State private var searchText = ""

  var body: some View {
    List {
      ListItem {
        VStack(alignment: .leading, spacing: 0) {
          HStack(spacing: 4) {
            Text("Title")
              .textStyle(.body.standard.regular)
              .foregroundStyle(Color.ds.text.neutral.standard)
            Image.ds.group.outlined
              .resizable()
              .frame(width: imageDimension, height: imageDimension)
              .foregroundStyle(Color.ds.text.neutral.quiet)
            DS.Badge("Badge")
              .controlSize(.small)
              .style(mood: .neutral, intensity: .quiet)
          }
          Text("Description")
            .textStyle(.body.reduced.regular)
            .foregroundStyle(Color.ds.text.neutral.quiet)
        }
      } leadingAccessory: {
        Thumbnail.User.single(nil)
          .controlSize(.small)
      } actions: {
        FieldAction.CopyContent(action: {})
        FieldAction.Button(
          "Open External Link",
          image: .ds.action.openExternalLink.outlined,
          action: {}
        )
        FieldAction.Button(
          "Open External Link",
          image: .ds.action.openExternalLink.outlined,
          action: {}
        )
      }

      ListItem(
        title: "Title",
        description: "Description",
        badge: "Badge",
        leadingAccessory: {
          Thumbnail.User.single(nil)
            .controlSize(.small)
        },
        actions: {
          FieldAction.CopyContent(action: {})
          FieldAction.Button(
            "Open External Link",
            image: .ds.action.openExternalLink.outlined,
            action: {}
          )
        }
      )

      ListItem(title: "Test", description: "") {
        Thumbnail.User.single(nil)
          .controlSize(.small)
      }

      ListItem(title: "Title", description: "This is a longer description") {
        EmptyView()
      }

      ListItem {
        ListItemLabel(
          "Test",
          description: "This is a description",
          badge: nil
        ) {
          Image.ds.group.outlined
            .resizable()
        }
      } leadingAccessory: {
        Thumbnail.User.group
          .controlSize(.small)
      } actions: {
        FieldAction.CopyContent(action: {})
      }

      ListItem {
        ListItemLabel("Boursorama") {
          ListItemCreditCardLabelDescription(
            icon: Image(systemName: "creditcard"),
            number: "374245455400126",
            expirationDate: .now.addingTimeInterval(6_000_000)
          )
        }
      } leadingAccessory: {
        Thumbnail.User.single(nil)
          .controlSize(.small)
      } actions: {
        FieldAction.Menu("More", image: .ds.action.more.outlined) {
          FieldAction.Button("Action", image: .ds.action.add.outlined) {}
        }
        FieldAction.CopyContent(action: {})
      }
    }
    .listStyle(.ds.insetGrouped)
    .tint(.ds.text.brand.quiet)
    .searchable(text: $searchText)
    .highlightedValue(searchText)
  }
}

#Preview {
  NavigationStack {
    PreviewContent()
  }
}
