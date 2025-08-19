import CoreLocalization
import DesignSystem
import SwiftUI

public struct FeatureCard<Content: View>: View {
  @ViewBuilder
  let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      content()
    }
    .padding(16)
    .background(Color.ds.container.agnostic.neutral.supershy)
    .containerShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
  }
}

public struct FeatureRow: View {
  let asset: ExpressiveIcon
  let title: String
  let description: String

  public init(
    asset: ExpressiveIcon,
    title: String,
    description: String
  ) {
    self.asset = asset
    self.title = title
    self.description = description
  }

  public var body: some View {
    HStack(spacing: 16) {
      asset
        .controlSize(.regular)
        .style(mood: .neutral, intensity: .quiet)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .textStyle(.title.block.medium)
          .foregroundStyle(Color.ds.text.neutral.standard)

        Text(description)
          .textStyle(.body.reduced.regular)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .multilineTextAlignment(.leading)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  FeatureCard {
    FeatureRow(
      asset: ExpressiveIcon(.ds.folder.outlined),
      title: CoreL10n.CollectionsIntro.Subtitle1.v2,
      description: CoreL10n.CollectionsIntro.Description1.v2
    )

    FeatureRow(
      asset: ExpressiveIcon(.ds.action.share.outlined),
      title: CoreL10n.CollectionsIntro.subtitle2,
      description: CoreL10n.CollectionsIntro.description2
    )
  }
}
