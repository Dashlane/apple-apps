import SwiftUI
import UIDelight

struct TextInputReadOnlyValueView: View {
  @Environment(\.isInputSecure) private var isSecure
  @Environment(\.textFieldIsSecureValueRevealed) private var isRevealed
  @Environment(\.textFieldColorHighlightingMode) private var colorHighlightingMode
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.style.mood) private var mood

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
        .foregroundStyle(Color.ds.text.neutral.catchy)
      }
    } icon: {

    }
    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.6 : 0.8)
    .labelStyle(.fieldContent)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(value))
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

#Preview("Emphasized") {
  VStack(alignment: .leading) {
    TextInputReadOnlyValueView("dashlane-challenge.company.com")
    TextInputReadOnlyValueView("This is my content")
    TextInputReadOnlyValueView("_")
      .secureInput()
    TextInputReadOnlyValueView("_")
      .secureInput()
      .textFieldRevealSecureValue(true)
      .textFieldColorHighlightingMode(.password)
    TextInputReadOnlyValueView("_")
      .textFieldColorHighlightingMode(.url)
    TextInputReadOnlyValueView("_")
      .textFieldColorHighlightingMode(.url)
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
      .textFieldColorHighlightingMode(.password)
    TextInputReadOnlyValueView("_")
      .textFieldColorHighlightingMode(.url)
    TextInputReadOnlyValueView("_")
      .textFieldColorHighlightingMode(.url)
      .style(.error)
  }
  .fieldDisabledEditionAppearance(.discrete)
}
