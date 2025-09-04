import SwiftUI
import UIDelight

struct FieldContentLabelStyle: LabelStyle {
  @Environment(\.fieldEditionDisabled) private var fieldEditionDisabled
  @Environment(\.fieldDisabledEditionAppearance) private var disabledEditionAppearance

  @ScaledMetric private var cornerRadius = 4
  @ScaledMetric private var trailingPadding = 4
  @ScaledMetric private var iconDimension = 12
  @ScaledMetric private var iconContainerDimension = 20

  func makeBody(configuration: Configuration) -> some View {
    switch (fieldEditionDisabled, disabledEditionAppearance) {
    case (_, .discrete),
      (_, .none),
      (false, .emphasized):
      Label(
        title: { configuration.title },
        icon: { configuration.icon }
      )
      .labelStyle(TitleOnlyLabelStyle())
    case (true, .emphasized):
      Label(
        title: { configuration.title },
        icon: {
          Image.ds.lock.filled
            .resizable()
            .frame(width: iconDimension, height: iconDimension)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .frame(width: iconContainerDimension, height: iconContainerDimension)
        }
      )
      .labelStyle(LeadingIconLabelStyle(spacing: 0))
      .padding(.trailing, trailingPadding)
      .background(
        Color.ds.container.agnostic.neutral.standard,
        in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
      )
    }

  }
}

extension LabelStyle where Self == FieldContentLabelStyle {
  static var fieldContent: FieldContentLabelStyle {
    FieldContentLabelStyle()
  }
}

#Preview {
  List {
    Label("Label", systemImage: "heart")
      .labelStyle(.fieldContent)
    Label("Label (field disabled emphasized)", systemImage: "heart")
      .labelStyle(.fieldContent)
      .fieldEditionDisabled(true, appearance: .emphasized)
    Label("Label (field disabled discrete)", systemImage: "heart")
      .labelStyle(.fieldContent)
      .fieldEditionDisabled(true, appearance: .discrete)
  }.listStyle(.ds.insetGrouped)

}
