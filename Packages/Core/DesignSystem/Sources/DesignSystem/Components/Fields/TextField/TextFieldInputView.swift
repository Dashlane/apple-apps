import CoreLocalization
import Foundation
import SwiftUI

struct TextFieldInputView: View {
  @Environment(\.fieldLabelHiddenOnFocus) private var isLabelPersistencyDisabled
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.textFieldColorHighlightingMode) private var colorHighlightingMode
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.fieldEditionDisabled) private var editionDisabled
  @Environment(\.style.mood) private var mood
  @Environment(\.fieldRequired) private var isRequired

  @ScaledMetric private var placeholderTransitionVerticalOffset = 14
  @ScaledMetric(relativeTo: .body) private var minimumHeight = 22

  private let label: String
  private let placeholder: String?
  private let value: Binding<String>

  @State private var displayPlaceholder = false

  @FocusState private var isFocused

  init(label: String, placeholder: String?, value: Binding<String>) {
    self.label = label
    self.placeholder = placeholder
    self.value = value
  }

  var body: some View {
    plainField
      .accessibilityLabel(accessibilityLabel)
      .focused($isFocused)
      .background(placeholderView, alignment: .leadingFirstTextBaseline)
      .frame(minHeight: minimumHeight)
      .onChange(of: shouldDisplayPlaceholder) { _, newValue in
        let stringValue = value.wrappedValue
        let disableAnimation = !newValue && !stringValue.isEmpty
        withAnimation(disableAnimation ? nil : placeholderAnimation) {
          displayPlaceholder = newValue
        }
      }
      .transformEnvironment(\.style) { style in
        style = Style(mood: style.mood, intensity: .quiet, priority: style.priority)
      }
      .accessibilityAddTraits(editionDisabled ? .isStaticText : [])
  }

  @ViewBuilder
  private var placeholderView: some View {
    if let placeholder, displayPlaceholder {
      Text(placeholder)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .transition(
          isLabelPersistencyDisabled
            ? .opacity.combined(with: .offset(y: placeholderTransitionVerticalOffset))
            : .opacity
        )
        .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.6 : 0.8)
    }
  }

  private var placeholderAnimation: Animation {
    if isLabelPersistencyDisabled {
      return .spring(response: 0.3, dampingFraction: 0.72)
    }
    return .easeInOut(duration: 0.3)
  }

  private var plainField: some View {
    TextField("", text: value)
      .foregroundStyle(.textInputValue)
      .textStyle(.body.standard.regular)
      .opacity(isFocused || colorHighlightingMode == nil ? 1 : 0.001)
      .overlay(attributedTextView, alignment: .leadingFirstTextBaseline)
      .accessibilityAddTraits(editionDisabled ? .isStaticText : [])
  }

  private var shouldDisplayPlaceholder: Bool {
    guard placeholder != nil else { return false }
    return isFocused && value.wrappedValue.isEmpty
  }

  private var accessibilityLabel: Text {
    if let placeholder, !placeholder.isEmpty {
      return Text(placeholder)
    }
    return Text("")
  }

  @ViewBuilder
  private var attributedTextView: some View {
    if colorHighlightingMode != nil {
      Text(
        .urlAttributedString(
          from: value.wrappedValue,
          dynamicTypeSize: dynamicTypeSize,
          mood: mood
        )
      )
      .allowsHitTesting(false)
      .accessibilityHidden(true)
      .opacity(isFocused ? 0 : 1)
    }
  }
}

private struct PreviewContent: View {
  @FocusState private var isFocused: Bool
  @State private var text = "Value"

  var body: some View {
    VStack {
      TextFieldInputView(
        label: "Test",
        placeholder: "Placeholder",
        value: $text
      )
      .focused($isFocused)
      .background(.ds.container.expressive.neutral.quiet.idle)

      TextFieldInputView(
        label: "Test",
        placeholder: nil,
        value: $text
      )
      .background(.ds.container.expressive.neutral.quiet.idle)
      .disabled(true)

      TextFieldInputView(
        label: "Test",
        placeholder: nil,
        value: .constant("This is a test")
      )
      .style(.error)
      .background(.ds.container.expressive.neutral.quiet.idle)

      TextFieldInputView(
        label: "Test",
        placeholder: nil,
        value: .constant("_")
      )
      .textFieldColorHighlightingMode(.url)
      .background(.ds.container.expressive.neutral.quiet.idle)

      Button("Toggle focus") { isFocused.toggle() }
      Text(verbatim: "isFocused: \(isFocused)")
    }
  }
}

#Preview {
  PreviewContent()
    .padding(.horizontal)
}
