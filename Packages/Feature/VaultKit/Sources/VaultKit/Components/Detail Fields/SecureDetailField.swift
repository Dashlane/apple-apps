#if os(iOS)
import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

extension String: ReferenceConvertible {
    public typealias ReferenceType = NSString
}

public struct SecureDetailField<FeedbackContent: View>: DetailField {
    public typealias OnRevealAction = (_ fieldType: DetailFieldType) -> Void

    public enum Action: Identifiable {
        case copy((_ value: String, _ fieldType: DetailFieldType) -> Void)
        case other(title: String, image: Image, action: () -> Void)

        public var id: String {
            switch self {
            case .copy:
                return "copy"
            case .other(let title, _, _):
                return "other\(title)"
            }
        }
    }

    public let title: String

    @Binding
    var text: String

    @Binding
    var shouldReveal: Bool

    @FocusState
    var isFocused

    @State
    var isFocusedBinding: Bool = false

    @Environment(\.detailMode)
    var detailMode

    @Environment(\.detailFieldType)
    public var fiberFieldType

    let onRevealAction: OnRevealAction?
    let actions: [Action]
    let feedback: FeedbackContent?

    let formatter: Formatter?
    let obfuscatingFormatter: Formatter?
    let hasDisplayEmptyIndicator: Bool

    var effectiveFormatter: Formatter? {
        return shouldReveal ? formatter : obfuscatingFormatter
    }

    var isColored: Bool

    var shouldBeDisabled: Bool {
        return !detailMode.isEditing
    }

        var shouldUseNewTextField: Bool {
                        if Device.isMac, #unavailable(macOS 13.0) {
            return false
        }
        return obfuscatingFormatter == nil && formatter == nil
    }

    public init(
        title: String,
        text: Binding<String>,
        shouldReveal: Binding<Bool>,
        onRevealAction: OnRevealAction? = nil,
        hasDisplayEmptyIndicator: Bool = true,
        formatter: Formatter? = nil,
        obfuscatingFormatter: Formatter? = nil,
        isColored: Bool = false,
        actions: [Action] = [],
        feedback: FeedbackContent?
    ) {
        self.title = title
        self._text = text
        self._shouldReveal = shouldReveal
        self.onRevealAction = onRevealAction
        self.hasDisplayEmptyIndicator = hasDisplayEmptyIndicator
        self.formatter = formatter
        self.obfuscatingFormatter = obfuscatingFormatter
        self.isColored = isColored
        self.actions = actions
        self.feedback = feedback
    }

    public init(
        title: String,
        text: Binding<String>,
        shouldReveal: Binding<Bool>,
        onRevealAction: OnRevealAction? = nil,
        hasDisplayEmptyIndicator: Bool = true,
        formatter: Formatter? = nil,
        obfuscatingFormatter: Formatter? = nil,
        isColored: Bool = false,
        actions: [Action] = []
    ) where FeedbackContent == EmptyView {
        self.init(
            title: title,
            text: text,
            shouldReveal: shouldReveal,
            onRevealAction: onRevealAction,
            hasDisplayEmptyIndicator: hasDisplayEmptyIndicator,
            formatter: formatter,
            obfuscatingFormatter: obfuscatingFormatter,
            isColored: isColored,
            actions: actions,
            feedback: EmptyView()
        )
    }

    public var body: some View {
        HStack {
            if !detailMode.isEditing {
                textfield
            } else if !Device.isMac {
                textfield
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.isFocused = true
                        self.isFocusedBinding = true
                    }
            } else {
                textfield
            }

            if detailMode != .limitedViewing, !shouldUseNewTextField {
                if text.isEmpty {
                    if hasDisplayEmptyIndicator {
                        Image.ds.feedback.info.outlined
                            .fiberAccessibilityLabel(Text(fiberFieldType.infoButtonAccessibilityLabel))
                    }
                } else {
                    Toggle(isOn: $shouldReveal) {
                        EmptyView()
                    }
                    .toggleStyle(RevealToggleStyle(fieldType: fiberFieldType, action: { onRevealAction?($0) }))

                    ForEach(actions) { action in
                        if case .copy(let action) = action {
                            Button(
                                action: { action(text, fiberFieldType) },
                                label: {
                                    Image.ds.action.copy.outlined
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(Color.ds.text.brand.quiet)
                                }
                            )
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text(L10n.Core.kwCopy))
                        }
                    }
                }
            }
        }
        .animation(Device.isMac ? .none : .default, value: shouldReveal)
    }

    var textfield: some View {
        ZStack {
            if shouldUseNewTextField {
                newField
            } else if !detailMode.isEditing && shouldReveal && isColored {
                PasswordText(text: text, formatter: formatter)
            } else if detailMode.isEditing || (!shouldReveal && obfuscatingFormatter == nil) {
                                previousField
            } else {
                Text("\(text, formatter: effectiveFormatter)")
                    .font(Font.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(1)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
        .labeledIfNeeded(title, !shouldUseNewTextField)
        .environment(\.editMode, detailMode.isEditing ? .constant(.active) : .constant(.inactive))
    }

    private var previousField: some View {
        PasswordField(title, text: $text, isFocused: $isFocusedBinding)
            .passwordFieldSecure(!shouldReveal)
            .textInputAutocapitalization(.never)
            .passwordFieldMonospacedFont(true)
            .disabled(shouldBeDisabled)
            .fiberAccessibilityHint(!shouldBeDisabled ? Text(L10n.Core.detailItemViewAccessibilityEditableHint) : Text(""))
    }

    private var newField: some View {
        DS.PasswordField(
            title,
            text: $text,
            actions: {
                ForEach(actions, id: \.id) { action in
                    switch action {
                    case .copy(let action):
                        if !text.isEmpty {
                            TextFieldAction.Button(L10n.Core.kwCopy, image: .ds.action.copy.outlined) { action(text, fiberFieldType) }
                        }
                    case .other(let title, let image, let action):
                        TextFieldAction.Button(title, image: image, action: action)
                    }
                }
            }, feedback: {
                if let feedback {
                    feedback
                }
            }
        )
        .onRevealSecureValue { onRevealAction?(fiberFieldType) }
        .focused($isFocused)
        .passwordFieldSecure(!shouldReveal)
        .textInputAutocapitalization(.never)
        .passwordFieldMonospacedFont(true)
        .fiberAccessibilityHint(!shouldBeDisabled ? Text(L10n.Core.detailItemViewAccessibilityEditableHint) : Text(""))
    }
}

public struct PasswordText: View {
    var text: String
    let formatter: Formatter?

    public init(text: String, formatter: Formatter? = nil) {
        self.text = text
        self.formatter = formatter
    }

    public var body: some View {
        text.reduce(Text(""), { (currentText, char) -> Text in
            let tempText = Text("\(String(char), formatter: formatter)")
                .foregroundColor(Color(passwordChar: char))
            return currentText + tempText
            })
        .font(Font.system(.body, design: .monospaced))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RevealToggleStyle: ToggleStyle {
    let fieldType: DetailFieldType
    let action: SecureDetailField.OnRevealAction

    private func image(for configuration: Self.Configuration) -> Image {
        return configuration.isOn ? .ds.action.hide.outlined : .ds.action.reveal.outlined
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        image(for: configuration)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .fiberAccessibilityLabel(Text(configuration.isOn ? L10n.Core.kwHide : L10n.Core.kwReveal))
            .foregroundColor(Color.ds.text.brand.quiet)
            .extendTappableArea()
            .animation(nil, value: configuration.isOn)
            .onTapGesture {
                self.action(self.fieldType)
            }
    }
}

private extension View {
    @ViewBuilder
    func extendTappableArea() -> some View {
        if Device.isMac {
            self
                .padding(2)
                .contentShape(Rectangle())
        } else {
            self
        }
    }

    @ViewBuilder
    func labeledIfNeeded(_ label: String, _ needed: Bool) -> some View {
        if needed {
            self.labeled(label)
        } else {
            self
        }
    }
}

struct SecureDetailField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            Group {
                SecureDetailField(title: "Title", text: .constant("test"), shouldReveal: .constant(false))
                SecureDetailField(title: "Title", text: .constant("test"), shouldReveal: .constant(true)).environment(\.detailMode, .updating)
                SecureDetailField(title: "Title", text: .constant(""), shouldReveal: .constant(false))
            }
            .background(Color.ds.background.default)
        }
        .previewLayout(.sizeThatFits)
    }
}

private extension DetailFieldType {
    var infoButtonAccessibilityLabel: String {
        switch self {
        case .cardNumber, .socialSecurityNumber, .bankAccountBIC, .bankAccountIBAN:
            return L10n.Core.detailItemViewAccessibilityNumberMissingIconLabel
        default:
            return L10n.Core.detailItemViewAccessibilityPasswordMissingIconLabel
        }
    }
}
#endif
