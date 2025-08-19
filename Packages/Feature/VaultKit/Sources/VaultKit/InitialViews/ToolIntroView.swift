import CoreLocalization
import DesignSystem
import SwiftUI

public struct ToolIntroView<Content: View>: View {
  @ViewBuilder
  var content: () -> Content

  let icon: ExpressiveIcon
  let title: String

  public init(
    icon: ExpressiveIcon,
    title: String,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.icon = icon
    self.title = title
    self.content = content
  }

  public var body: some View {
    VStack(spacing: 24) {
      icon
        .style(mood: .brand, intensity: .quiet)
        .controlSize(.extraLarge)

      Text(title)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.center)

      content()
    }
    .padding(.horizontal, 24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }
}

#Preview("Sharing") {
  ToolIntroView(
    icon: ExpressiveIcon(.ds.shared.outlined),
    title: CoreL10n.SharingIntro.title
  ) {
    VStack(spacing: 24) {
      FeatureCard {
        FeatureRow(
          asset: ExpressiveIcon(.ds.action.share.outlined),
          title: CoreL10n.SharingIntro.subtitle1,
          description: CoreL10n.SharingIntro.description1
        )
      }

      Button {

      } label: {
        Label(
          CoreL10n.SharingIntro.Cta.v1,
          icon: .ds.arrowRight.outlined
        )
      }
      .buttonStyle(.designSystem(.iconTrailing(.sizeToFit)))
    }
  }
}
