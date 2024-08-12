import SwiftUI

public typealias IconlessListItemLabel = ListItemLabel<
  ListItemLabelTitle<EmptyView>, ListItemLabelDescription
>

public struct ListItemLabel<Title: View, Description: View>: View {
  private let description: Description
  private let title: Title

  public init(
    @ViewBuilder title: () -> Title,
    @ViewBuilder description: () -> Description
  ) {
    self.title = title()
    self.description = description()
  }

  public init(
    _ title: String,
    @ViewBuilder description: () -> Description
  ) where Title == ListItemLabelTitle<EmptyView> {
    self.title = ListItemLabelTitle(title)
    self.description = description()
  }

  public init<Icons: View>(
    _ title: String,
    description: String,
    badge: String? = nil,
    @ViewBuilder icons: () -> Icons
  ) where Title == ListItemLabelTitle<Icons>, Description == ListItemLabelDescription {
    self.init {
      ListItemLabelTitle(title, badge: badge, icons: icons)
    } description: {
      ListItemLabelDescription(description)
    }
  }

  public init(
    _ title: String,
    description: String,
    badge: String? = nil
  ) where Title == ListItemLabelTitle<EmptyView>, Description == ListItemLabelDescription {
    self.init(title, description: description, badge: badge) {
      EmptyView()
    }
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      title
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .lineLimit(1)

      description
        .textStyle(.body.reduced.regular)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .labelStyle(ListItemLabelDescriptionLabelStyle())
        .lineLimit(1)
    }
  }
}

struct ListItemLabelDescriptionLabelStyle: LabelStyle {
  @ScaledMetric private var iconHeight = 12

  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 4) {
      configuration.icon
        .aspectRatio(contentMode: .fit)
        .frame(height: iconHeight)
      configuration.title
    }
    .textStyle(.body.reduced.regular)
    .foregroundStyle(Color.ds.text.neutral.quiet)
  }
}

#Preview {
  ListItemLabel("Title", description: "Description", badge: "Badge") {
    Image.ds.group.outlined
      .resizable()
    Image.ds.activityLog.outlined
      .resizable()
  }
}

#Preview("ListItemCreditCardLabelDescription [JA]") {
  ListItemCreditCardLabelDescription(
    icon: .ds.fingerprint.outlined,
    number: "123456789123",
    expirationDate: .now
  )
  .environment(\.locale, .init(identifier: "ja"))
}
