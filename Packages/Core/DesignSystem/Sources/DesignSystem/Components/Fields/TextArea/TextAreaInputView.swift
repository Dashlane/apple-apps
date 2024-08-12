import SwiftUI

struct TextAreaInputView: View {
  @Environment(\.editionDisabled) private var editionDisabled
  @Environment(\.textInputDisabledEditionAppearance) private var disabledEditionAppearance
  @Environment(\.fieldLabelPersistencyDisabled) private var isLabelPersistencyDisabled

  @ScaledMetric private var placeholderTransitionVerticalOffset = 14

  private let label: String
  private let placeholder: String?
  private let text: Binding<String>

  @FocusState private var isFocused

  init(label: String, placeholder: String?, text: Binding<String>) {
    self.label = label
    self.placeholder = placeholder
    self.text = text
  }

  var body: some View {
    if editionDisabled {
      TextInputReadOnlyValueView(text.wrappedValue)
        .frame(maxWidth: .infinity, alignment: .leading)
    } else {
      TextField("", text: text, axis: .vertical)
        .focused($isFocused)
        ._foregroundStyle(.textInputValue)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .allowsHitTesting(!editionDisabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(editionDisabled ? .isStaticText : [])
    }
  }

  private var accessibilityLabel: Text {
    if let placeholder {
      return Text(placeholder)
    }
    return Text(label)
  }
}

#Preview("Editable") {
  VStack {
    TextAreaInputView(
      label: "Label",
      placeholder: "Placeholder",
      text: .constant("This is a really long value that should spawn on multiple lines.")
    )
  }
  .padding(.horizontal)
}

#Preview("Edition Disabled (Emphasized)") {
  VStack {
    TextAreaInputView(
      label: "Label",
      placeholder: "Placeholder",
      text: .constant("This is a really long value that should spawn on multiple lines.")
    )
  }
  .padding(.horizontal)
  .editionDisabled()
}

#Preview("Edition Disabled (Discrete)") {
  VStack {
    TextAreaInputView(
      label: "Label",
      placeholder: "Placeholder",
      text: .constant("This is a really long value that should spawn on multiple lines.")
    )
  }
  .padding(.horizontal)
  .editionDisabled(appearance: .discrete)
}
