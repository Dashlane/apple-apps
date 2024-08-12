import Foundation
import SwiftUI

struct PasswordFieldInputView: View {
  @Environment(\.self) private var environment
  @Environment(\.textFieldIsSecureValueRevealed) private var isSecureValueRevealed
  @Environment(\.fieldLabelPersistencyDisabled) private var isLabelPersistencyDisabled
  @Environment(\.editionDisabled) private var editionDisabled
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.isEnabled) private var isEnabled

  @ScaledMetric private var placeholderTransitionVerticalOffset = 14
  @ScaledMetric(relativeTo: .body) private var minimumHeight = 22

  private let label: String
  private let text: Binding<String>
  private let placeholder: String?

  @State private var displayPlaceholder = false
  @FocusState private var isFocused

  private enum Field {
    case plain
    case secure
  }

  @FocusState private var focusedField: Field?
  @State private var visibleField: Field = .secure

  init(label: String, text: Binding<String>, placeholder: String?) {
    self.label = label
    self.text = text
    self.placeholder = placeholder
  }

  var body: some View {
    ZStack {
      if visibleField == .secure && !isSecureValueRevealed {
        secureField
          .focused($focusedField, equals: .secure)
      } else {
        plainField
          .focused($focusedField, equals: .plain)
      }
    }
    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.6 : 0.8)
    .accessibilityLabel(accessibilityLabel)
    .focused($isFocused)
    .background(placeholderView, alignment: .leadingFirstTextBaseline)
    .frame(minHeight: minimumHeight)
    .onChange(of: isSecureValueRevealed) { newValue in
      guard isFocused else { return }

      focusedField = newValue ? .plain : .secure
      DispatchQueue.main.async {
        visibleField = newValue ? .plain : .secure
      }
    }
    .onChange(of: shouldDisplayPlaceholder) { newValue in
      let disableAnimation = !newValue && !text.wrappedValue.isEmpty
      withAnimation(
        disableAnimation
          ? nil
          : Animation.textInputPlaceholderAnimation(in: environment)
      ) {
        displayPlaceholder = newValue
      }
    }
  }

  private var plainField: some View {
    TextField("", text: text)
      ._foregroundStyle(.textInputValue)
      .textStyle(
        text.wrappedValue.isEmpty
          ? .body.standard.regular
          : .body.standard.monospace
      )
      #if canImport(UIKit)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
      #endif
      .opacity(displayAttributedValue ? 0.001 : 1)
      .animation(.default, value: displayAttributedValue)
      .overlay(attributedTextView, alignment: .leadingFirstTextBaseline)
      .accessibilityAddTraits(editionDisabled ? .isStaticText : [])
  }

  private var secureField: some View {
    SecureField("", text: text)
      ._foregroundStyle(.textInputValue)
      .accessibilityAddTraits(editionDisabled ? .isStaticText : [])
      #if !targetEnvironment(macCatalyst)
        .textContentType(.oneTimeCode)
      #endif
  }

  @ViewBuilder
  private var placeholderView: some View {
    if let placeholder, displayPlaceholder {
      Text(placeholder)
        .foregroundColor(.ds.text.neutral.quiet)
        .transition(
          isLabelPersistencyDisabled
            ? .opacity.combined(with: .offset(y: placeholderTransitionVerticalOffset))
            : .opacity
        )
    }
  }

  @ViewBuilder
  private var attributedTextView: some View {
    Text(.passwordAttributedString(from: text.wrappedValue, with: dynamicTypeSize))
      .allowsHitTesting(false)
      .accessibilityHidden(true)
      .opacity(displayAttributedValue ? (isEnabled ? 1 : 0.5) : 0)
      .animation(.default, value: displayAttributedValue)
  }

  private var accessibilityLabel: Text {
    if let placeholder, !placeholder.isEmpty {
      return Text(placeholder)
    }
    return Text(label)
  }

  private var displayAttributedValue: Bool {
    guard !text.wrappedValue.isEmpty, !isFocused
    else { return false }
    return isSecureValueRevealed
  }

  private var shouldDisplayPlaceholder: Bool {
    guard placeholder != nil else { return false }
    return isFocused && text.wrappedValue.isEmpty
  }
}
