import SwiftUI
import UIDelight

struct TextFieldInputContainer<ActionsContent: View>: View {
    typealias Action = TextFieldAction

    @Environment(\.textFieldAppearance) private var appearance
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.textFieldLabelPersistencyDisabled) private var isLabelPersistencyDisabled
    @Environment(\.editionDisabled) private var editionDisabled
    @Environment(\.textFieldDisabledEditionAppearance) private var disabledEditionAppearance
    @Environment(\.textFieldFeedbackAppearance) private var feedbackAppearance
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var smallLabelAnchor: Anchor<CGRect>?
    @State private var largeLabelAnchor: Anchor<CGRect>?
    @State private var isLabelAtEndPosition = false

    @ScaledMetric private var minimumHeight = 48
    @ScaledMetric private var leadingContentPadding = 16
    @ScaledMetric private var actionsContainerHorizontalPadding = 4
    @ScaledMetric private var actionLessTrailingContentPadding = 16
    @ScaledMetric private var verticalContentPadding = 4
    @ScaledMetric private var nonPersistentLabelTransitionVerticalOffset = -14
    @ScaledMetric private var inputAreaContainerSpacing = 2

    private let label: String
    private let placeholder: String?
    private let text: Binding<String>
    private let actionsContent: ActionsContent

    @FocusState private var isFocused

    init(
        _ label: String,
        placeholder: String?,
        text: Binding<String>,
        @ViewBuilder actionsContent: () -> ActionsContent
    ) {
        self.label = label
        self.placeholder = placeholder
        self.text = text
        self.actionsContent = actionsContent()
        _isLabelAtEndPosition = .init(initialValue: !text.wrappedValue.isEmpty)
    }

    var body: some View {
        AdaptiveHStack(horizontalAlignment: .leading, spacing: 0) {
            inputAreaContainer
            actionsContainer
        }
        .padding(.trailing, isGrouped ? -actionLessTrailingContentPadding : 0)
        .background(TextFieldBackground(isFocused: isFocused))
    }

        private var inputAreaContainer: some View {
                VStack(alignment: .leading, spacing: editionDisabled ? inputAreaContainerSpacing : 0) {
            if !isLabelPersistencyDisabled {
                smallLabelView
            }
            if editionDisabled && disabledEditionAppearance == .emphasized {
                TextFieldReadOnlyValueView(text.wrappedValue)
            } else {
                TextFieldInputView(
                    label: label,
                    placeholder: placeholder,
                    text: text
                )
                .focused($isFocused)
            }
        }
        .frame(maxWidth: .infinity, minHeight: minimumHeight, alignment: .leading)
        .overlay(largeLabelView, alignment: .leading)
        .overlay(labelView, alignment: .leading)
        .allowsHitTesting(isFocused)
        .padding(.leading, effectiveLeadingContentPadding)
        .padding(.trailing, effectiveTrailingContentPadding)
        .padding(.vertical, effectiveVerticalContentPadding)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isFocused {
                performHapticFeedback()
            }
            isFocused = true
        }
        .allowsHitTesting(!shouldDisableInteractivity)
        .onChange(of: isFocused) { isFocused in
            guard text.wrappedValue.isEmpty else { return }
            moveLabel(toEndPosition: isFocused)
        }
        .onChange(of: text.wrappedValue) { text in
            guard !isFocused else { return }
            moveLabel(toEndPosition: !text.isEmpty)
        }
        .onChange(of: editionDisabled) { editionDisabled in
            moveLabel(toEndPosition: editionDisabled || !text.wrappedValue.isEmpty)
        }
        .onPreferenceChange(SmallLabelBoundsPreferenceKey.self) { preferenceValue in
            guard let anchor = preferenceValue.first else { return }
            smallLabelAnchor = anchor
        }
        .onPreferenceChange(LargeLabelBoundsPreferenceKey.self) { preferenceValue in
            guard let anchor = preferenceValue.first else { return }
            largeLabelAnchor = anchor
        }
    }

        private var actionsContainer: some View {
        TextFieldActionsStack {
            actionsContent
        }
                        .buttonStyle(BorderlessButtonStyle())
        .padding(.horizontal, actionsContainerHorizontalPadding)
    }

                private var smallLabelView: some View {
        Text(label)
            .textStyle(.body.helper.regular)
            .hidden()
            .accessibilityHidden(true)
            .anchorPreference(
                key: SmallLabelBoundsPreferenceKey.self,
                value: .bounds,
                transform: { [$0] }
            )
    }

            private var largeLabelView: some View {
        Text(label)
            .textStyle(.body.standard.regular)
            .hidden()
            .accessibilityHidden(true)
            .anchorPreference(
                key: LargeLabelBoundsPreferenceKey.self,
                value: .bounds,
                transform: { [$0] }
            )
    }

    @ViewBuilder
    private var labelView: some View {
        let foregroundColor = Color.labelForegroundColor(
            isEnabled: isEnabled,
            isFocused: isFocused,
            isLabelPersistencyDisabled: isLabelPersistencyDisabled,
            feedbackAppearance: feedbackAppearance
        )

        if isLabelPersistencyDisabled, !isLabelAtEndPosition {
            Text(label)
                .textStyle(
                    isLabelAtEndPosition
                    ? .body.helper.regular
                    : .body.standard.regular
                )
                .foregroundColor(foregroundColor)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
                .multilineTextAlignment(.leading)
                .allowsHitTesting(false)
                .transition(
                    .opacity.combined(
                        with: .offset(y: nonPersistentLabelTransitionVerticalOffset)
                    )
                )
                .accessibilityHidden(true)
        } else {
            GeometryReader { geometry in
                if let smallLabelAnchor, let largeLabelAnchor {
                    let anchor = isLabelAtEndPosition ? smallLabelAnchor : largeLabelAnchor

                    Text(label)
                        .textStyle(
                            isLabelAtEndPosition
                            ? .body.helper.regular
                            : .body.standard.regular
                        )
                        .foregroundColor(foregroundColor)
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                        .multilineTextAlignment(.leading)
                        .frame(
                            width: geometry[anchor].width,
                            height: geometry[anchor].height,
                            alignment: .leading
                        )
                        .offset(
                            x: geometry[anchor].minX,
                            y: geometry[anchor].minY
                        )
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private func moveLabel(toEndPosition endPosition: Bool) {
        guard endPosition != isLabelAtEndPosition else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
            isLabelAtEndPosition = endPosition
        }
    }

    private var effectiveLeadingContentPadding: Double {
        guard !isGrouped else { return 0 }
        return leadingContentPadding
    }

    private var effectiveVerticalContentPadding: Double {
        if isGrouped || isLabelPersistencyDisabled { return 0 }
        return verticalContentPadding
    }

    private var effectiveTrailingContentPadding: Double {
        guard !isGrouped else { return 0 }
        return actionsContent is EmptyView ? actionLessTrailingContentPadding : 0
    }

        private func performHapticFeedback() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator.softImpactGenerator.impactOccurred(intensity: 0.5)
        #endif
    }

        private var isGrouped: Bool {
        if case .grouped = appearance { return true }
        return false
    }

    private var shouldDisableInteractivity: Bool {
        return editionDisabled
    }

        private var accessibilityLabel: Text {
        if text.wrappedValue.isEmpty {
            let texts = [label, placeholder].compactMap { $0 }
            return Text(texts.joined(separator: ","))
        } else {
            return Text("\(label), \(text.wrappedValue)")
        }
    }
}

private struct SmallLabelBoundsPreferenceKey: PreferenceKey {
    typealias Value = [Anchor<CGRect>]

    static var defaultValue: Value = []

    static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value.append(contentsOf: nextValue())
    }
}

private struct LargeLabelBoundsPreferenceKey: PreferenceKey {
    typealias Value = [Anchor<CGRect>]

    static var defaultValue: Value = []

    static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value.append(contentsOf: nextValue())
    }
}

private extension Color {
    static func labelForegroundColor(
        isEnabled: Bool,
        isFocused: Bool,
        isLabelPersistencyDisabled: Bool,
        feedbackAppearance: TextFieldFeedbackAppearance?
    ) -> Color {
        if let feedbackAppearance, case .error = feedbackAppearance {
            return .ds.text.danger.quiet
        }
        let shouldSwitchColor = isFocused && !isLabelPersistencyDisabled
        let foregroundColor = isEnabled
        ? (shouldSwitchColor ? Color.ds.text.brand.quiet : .ds.text.neutral.quiet)
        : .ds.text.oddity.disabled
        return foregroundColor
    }
}

#if canImport(UIKit)
private extension UIImpactFeedbackGenerator {
    static let softImpactGenerator = UIImpactFeedbackGenerator(style: .soft)
}
#endif

struct TextFieldInputContainer_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var masterPassword = ""

        @State private var revealMasterPassword = false
        @State private var isPersistentLabelFieldFocused = false
        @State private var isNonPersistentLabelFieldFocused = false

        var body: some View {
            VStack(spacing: 16) {
                TextFieldInputContainer(
                    "Persistent Label",
                    placeholder: "Placeholder",
                    text: $masterPassword
                ) {
                    if !masterPassword.isEmpty {
                        TextFieldAction.RevealSecureContent(reveal: $revealMasterPassword)
                    }
                    TextFieldAction.Menu("More", image: .ds.action.more.outlined) {
                        Button(
                            action: {},
                            label: {
                                Label(
                                    title: { Text("Copy") },
                                    icon: { Image.ds.action.copy.outlined.resizable() }
                                )
                            }
                        )
                        if !masterPassword.isEmpty {
                            TextFieldAction.RevealSecureContent(reveal: $revealMasterPassword)
                        }
                        Button(
                            action: { isPersistentLabelFieldFocused.toggle() },
                            label: {
                                Label(
                                    title: {
                                        Text(isPersistentLabelFieldFocused ? "Unfocus" : "Focus")
                                    },
                                    icon: {
                                        Image.ds.action.edit.outlined.resizable()
                                    }
                                )
                            }
                        )
                    }
                }
                .secureInput()
                .textFieldRevealSecureValue(revealMasterPassword)

                TextFieldInputContainer(
                    "Label",
                    placeholder: "Placeholder",
                    text: $masterPassword
                ) {
                    TextFieldAction.Button(
                        "Test",
                        image: .ds.action.openExternalLink.outlined,
                        action: {}
                    )
                }
                .textFieldDisableLabelPersistency(true)

                TextFieldInputContainer(
                    "Label",
                    placeholder: "Placeholder",
                    text: .constant("Read-only value")
                ) {
                    EmptyView()
                }
                .editionDisabled()
            }
            .padding(.horizontal)
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        }
    }

    static var previews: some View {
        Preview()
    }
}
