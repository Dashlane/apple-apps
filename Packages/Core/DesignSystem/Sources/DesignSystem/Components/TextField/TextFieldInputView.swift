import SwiftUI

struct TextFieldInputView: View {
    @Environment(\.isInputSecure) private var isSecure
    @Environment(\.textFieldIsSecureValueRevealed) private var isSecureValueRevealed
    @Environment(\.textFieldLabelPersistencyDisabled) private var isLabelPersistencyDisabled
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.editionDisabled) private var editionDisabled
    @Environment(\.textFieldValueColorHighlightingMode) private var colorHighlightingMode
    @Environment(\.autocorrectionDisabled) private var autocorrectionDisabled
    @Environment(\.textFieldFeedbackAppearance) private var feedbackAppearance
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric private var placeholderTransitionVerticalOffset = 14

    private let label: String
    private let placeholder: String?
    private let text: Binding<String>

    @State private var displayPlaceholder = false

    @FocusState private var isFocused
    @State private var fieldMinimumHeight: CGFloat?

    init(label: String, placeholder: String?, text: Binding<String>) {
        self.label = label
        self.placeholder = placeholder
        self.text = text
    }

    var body: some View {
        ZStack {
            if displaySecureField {
                secureField
            } else {
                plainField
            }
        }
        .accessibilityLabel(accessibilityLabel)
        .focused($isFocused)
        .background(placeholderView, alignment: .leadingFirstTextBaseline)
        .frame(minHeight: fieldMinimumHeight)
        .background(dummyFields)
                .onChange(of: isSecure) { _ in
            guard isFocused else { return }
            DispatchQueue.main.async {
                isFocused = true
            }
        }
                .onChange(of: isSecureValueRevealed) { _ in
            guard isFocused else { return }
            DispatchQueue.main.async {
                isFocused = true
            }
        }
        .onChange(of: shouldDisplayPlaceholder) { newValue in
            let disableAnimation = !newValue && !text.wrappedValue.isEmpty
            withAnimation(disableAnimation ? nil : placeholderAnimation) {
                displayPlaceholder = newValue
            }
        }
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

    private var placeholderAnimation: Animation {
        if isLabelPersistencyDisabled {
            return .spring(response: 0.3, dampingFraction: 0.72)
        }
        return .easeInOut(duration: 0.3)
    }

        private var plainField: some View {
        TextField("", text: text)
            .foregroundColor(
                .foregroundColor(isEnabled: isEnabled, feedbackAppearance: feedbackAppearance)
            )
            .textStyle(
                useMonospacedFont
                ? .body.standard.monospace
                : .body.standard.regular
            )
            .textContentType(isSecure ? .oneTimeCode : nil)
            #if canImport(UIKit)
            .textInputAutocapitalization(isSecure ? .never : nil)
            .autocorrectionDisabled(isSecure ? true : autocorrectionDisabled)
            #endif
                                    .opacity(displayAttributedSecureValue ? 0.001 : 1)
            .animation(.default, value: displayAttributedSecureValue)
            .overlay(attributedTextView, alignment: .leadingFirstTextBaseline)
            .accessibilityAddTraits(editionDisabled ? .isStaticText : [])
    }

    private var secureField: some View {
        SecureField("", text: text)
            .foregroundColor(
                .foregroundColor(isEnabled: isEnabled, feedbackAppearance: feedbackAppearance)
            )
            .textContentType(.oneTimeCode)
            .accessibilityAddTraits(editionDisabled ? .isStaticText : [])
    }

                    private var dummyFields: some View {
        ZStack {
            SecureField("", text: text)
            TextField("", text: text)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
            }
        )
        .disabled(true)
        .allowsHitTesting(false)
        .hidden()
        .accessibilityHidden(true)
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            guard height != fieldMinimumHeight, height > 0 else { return }
            fieldMinimumHeight = height
        }
    }

        private var displayAttributedSecureValue: Bool {
        guard !text.wrappedValue.isEmpty, !isFocused && colorHighlightingMode != nil
        else { return false }
        return (isSecure && isSecureValueRevealed) || (!isSecure && colorHighlightingMode == .url)
    }

    private var displaySecureField: Bool {
        isSecure && !isSecureValueRevealed
    }

    private var useMonospacedFont: Bool {
        guard !text.wrappedValue.isEmpty else { return false }
        return isSecure
    }

    private var shouldDisplayPlaceholder: Bool {
        guard placeholder != nil else { return false }
        return isFocused && text.wrappedValue.isEmpty
    }

        private var accessibilityLabel: Text {
        if let placeholder {
            return Text(placeholder)
        }
        return Text(label)
    }

        private func attributedText(
        for colorHighlightingMode: TextFieldValueColorHighlightingMode
    ) -> AttributedString {
        let text = text.wrappedValue

        switch colorHighlightingMode {
        case .password:
            return .passwordAttributedString(
                from: text,
                dynamicTypeSize: dynamicTypeSize
            )
        case .url:
            return .urlAttributedString(
                from: text,
                feedbackAppearance: feedbackAppearance,
                dynamicTypeSize: dynamicTypeSize
            )
        }
    }

    @ViewBuilder
    private var attributedTextView: some View {
        if let colorHighlightingMode {
            Text(attributedText(for: colorHighlightingMode))
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .opacity(displayAttributedSecureValue ? (isEnabled ? 1 : 0.5) : 0)
                .animation(.default, value: displayAttributedSecureValue)
        }
    }
}

private extension Color {
    static func foregroundColor(
        isEnabled: Bool,
        feedbackAppearance: TextFieldFeedbackAppearance?
    ) -> Color {
        if let feedbackAppearance, case .error = feedbackAppearance {
            return .ds.text.danger.standard
        }
        return isEnabled ? .ds.text.neutral.catchy : .ds.text.oddity.disabled
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: Double = 0
    static func reduce(value: inout Double, nextValue: () -> Double) {}
}

struct TextFieldInputView_Previews: PreviewProvider {
    private struct Preview: View {
        @FocusState private var isFocused: Bool
        @State private var isSecure = false
        @State private var isSecureValueRevealed = false

        @State private var text = "_"

        var body: some View {
            VStack {
                TextFieldInputView(
                    label: "Test",
                    placeholder: "_",
                    text: $text
                )
                .focused($isFocused)
                .background(.ds.container.expressive.neutral.quiet.idle)

                TextFieldInputView(
                    label: "Test",
                    placeholder: nil,
                    text: $text
                )
                .background(.ds.container.expressive.neutral.quiet.idle)
                .disabled(true)

                Toggle("isSecure", isOn: $isSecure)
                Toggle("isSecureValueRevealed", isOn: $isSecureValueRevealed)
                Button(action: { isFocused.toggle() }, title: "Toggle focus")
                Text(verbatim: "isFocused: \(isFocused)")
            }
            .secureInput(isSecure)
            .textFieldRevealSecureValue(isSecureValueRevealed)
        }
    }

    static var previews: some View {
                        ZStack {
            Preview()
                .padding(.horizontal)
        }
    }
}
