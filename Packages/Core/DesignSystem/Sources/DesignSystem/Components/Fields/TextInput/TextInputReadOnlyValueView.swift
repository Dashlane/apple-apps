import SwiftUI
import UIDelight

struct TextInputReadOnlyValueView: View {
  @Environment(\.isInputSecure) private var isSecure
  @Environment(\.textFieldIsSecureValueRevealed) private var isRevealed
  @Environment(\.textColorHighlightingMode) private var colorHighlightingMode
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.style.mood) private var mood

  @ScaledMetric private var iconDimension = 12
  @ScaledMetric private var iconContainerDimension = 20

  private let value: String

  init(_ value: String) {
    self.value = value
  }

  var body: some View {
    Label {
      if useAttributedString {
        Text(attributedString)
      } else {
        Text(
          isSecure && !isRevealed
            ? String(repeating: "•", count: value.count)
            : value
        )
        .textStyle(
          isSecure
            ? .body.standard.monospace
            : .body.standard.regular
        )
        .foregroundColor(.ds.text.neutral.catchy)
      }
    } icon: {
      iconView
    }
    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.6 : 0.8)
    .labelStyle(CustomLabelStyle())
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(value))
  }

  private var iconView: some View {
    Image.ds.lock.filled
      .resizable()
      .frame(width: iconDimension, height: iconDimension)
      .foregroundColor(.ds.text.neutral.standard)
      .frame(width: iconContainerDimension, height: iconContainerDimension)
  }

  private var attributedString: AttributedString {
    switch colorHighlightingMode {
    case .password:
      return .passwordAttributedString(from: value, with: dynamicTypeSize)
    case .url:
      return .urlAttributedString(from: value, dynamicTypeSize: dynamicTypeSize, mood: mood)
    default:
      return AttributedString()
    }
  }

  private var useAttributedString: Bool {
    guard colorHighlightingMode != nil else { return false }
    return (isSecure && isRevealed) || !isSecure
  }
}

private struct CustomLabelStyle: LabelStyle {
  @Environment(\.textInputDisabledEditionAppearance) private var disabledEditionAppearance

  @ScaledMetric private var cornerRadius = 4
  @ScaledMetric private var trailingPadding = 4

  func makeBody(configuration: Configuration) -> some View {
    switch disabledEditionAppearance {
    case .discrete:
      Label(
        title: { configuration.title },
        icon: { configuration.icon }
      )
      .labelStyle(TitleOnlyLabelStyle())
    case .emphasized:
      Label(
        title: { configuration.title },
        icon: { configuration.icon }
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

#Preview("Emphasized") {
  VStack(alignment: .leading) {
    TextInputReadOnlyValueView("dashlane-challenge.company.com")
    TextInputReadOnlyValueView("This is my content")
    TextInputReadOnlyValueView("_")
      .secureInput()
    TextInputReadOnlyValueView("_")
      .secureInput()
      .textFieldRevealSecureValue(true)
      .textColorHighlightingMode(.password)
    TextInputReadOnlyValueView("_")
      .textColorHighlightingMode(.url)
    TextInputReadOnlyValueView("_")
      .textColorHighlightingMode(.url)
      .style(.error)
  }
}

#Preview("Discrete") {
  VStack(alignment: .leading) {
    TextInputReadOnlyValueView("dashlane-challenge.company.com")
    TextInputReadOnlyValueView("This is my content")
    TextInputReadOnlyValueView("_")
      .secureInput()
    TextInputReadOnlyValueView("_")
      .secureInput()
      .textFieldRevealSecureValue(true)
      .textColorHighlightingMode(.password)
    TextInputReadOnlyValueView("_")
      .textColorHighlightingMode(.url)
    TextInputReadOnlyValueView("_")
      .textColorHighlightingMode(.url)
      .style(.error)
  }
  .textInputDisabledEditionAppearance(.discrete)
}
