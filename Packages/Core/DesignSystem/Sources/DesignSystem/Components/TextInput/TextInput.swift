#if canImport(UIKit)
import SwiftUI
import UIKit
import CoreLocalization

public struct TextInput<TrailingAccessory: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.textInputLabel) private var label
    @Environment(\.textInputIsSecure) private var isSecure
    @Environment(\.textInputDisableEdition) private var disableEdition
    @Environment(\.style) private var style

    private enum FocusedField {
        case plain
        case secure
    }

    private let placeholder: String?
    private let trailingAccessory: TrailingAccessory

    @Binding private var text: String
    @FocusState private var focusedField: FocusedField?

    @State private var displaySecureFieldValueInPlainText = false
    @State private var displayTrailingAccessory: Bool
    @State private var disableSecurePlainField = true
    @State private var disableSecureField = false

    @ScaledMetric private var backgroundCornerRadius = 9
    @ScaledMetric private var minimumHeight = 44
    @ScaledMetric private var horizontalContentPadding = 14
    @ScaledMetric private var labelVerticalOffset = 8
    @ScaledMetric private var labelLeadingOffset = 12
    @ScaledMetric private var accessoryActionDimension = 20
    @ScaledMetric private var accessoryActionTapAreaDimension = 44

    public init(
        _ placeholder: String? = nil,
        text: Binding<String>,
        @ViewBuilder trailingAccessory: () -> TrailingAccessory = { EmptyView() }
    ) {
        self.placeholder = placeholder
        self.trailingAccessory = trailingAccessory()
        _text = text
        _displayTrailingAccessory = .init(initialValue: !text.wrappedValue.isEmpty)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: labelVerticalOffset) {
            labelView
            field
        }
        .accentColor(.ds.text.brand.standard)
    }

    @ViewBuilder
    private var field: some View {
        HStack(alignment: .center) {
            ZStack {
                if isSecure {
                    secureField
                } else {
                    plainField
                }
            }
            .accessibilityLabel(accessibilityLabel)
            textInputTrailingAccessoryView
        }
        .padding(.horizontal, horizontalContentPadding)
        .frame(maxWidth: .infinity, minHeight: minimumHeight)
        .background(fieldBackground)
                .onTapGesture {
            focusedField = displaySecureField ? .secure : .plain
        }
        .onChange(of: text) { newValue in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                displayTrailingAccessory = !newValue.isEmpty
            }
        }
        .onChange(of: displaySecureFieldValueInPlainText) { displaySecureText in
            focusedField = displaySecureText ? .plain : .secure
        }
    }
    
    private var accessibilityLabel: Text {
        if let label {
            return Text(label)
        } else if let placeholder {
            return Text(placeholder)
        } else {
            assertionFailure("Accessibility label cannot be inferred - neither text input label nor placeholder is set")
            return Text("")
        }
    }

    private var plainField: some View {
        TextField(text: $text) {
            if let placeholder {
                Text(placeholder)
            }
        }
        .focused($focusedField, equals: .plain)
        .disabled(disableEdition)
    }

    private var secureField: some View {
        ZStack {
            if displaySecureField {
                SecureField(text: $text) {
                    if let placeholder {
                        Text(placeholder)
                    }
                }
                .focused($focusedField, equals: .secure)
            } else {
                plainField
                    .font(.system(.body, design: text.isEmpty ? .default : .monospaced))
            }
        }
        .disabled(disableEdition)
        .textContentType(.oneTimeCode)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: displaySecureFieldValueInPlainText)
    }

    private var fieldBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
                .inset(by: isFocused ? -1.5 : -0.5)
                .fill(Color.focusBorderColor(isFocused: isFocused, intensity: style.intensity))
                .animation(.spring(response: 0.6, dampingFraction: 0.9), value: isFocused)
            RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
                .fill(Color.backgroundColor(intensity: style.intensity, colorScheme: colorScheme))
        }
    }

    @ViewBuilder
    private var labelView: some View {
        if let label {
            Text(label)
                .font(.system(.caption, design: .default).weight(.medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.leading, labelLeadingOffset)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var textInputTrailingAccessoryView: some View {
        if displayTrailingAccessory {
            if isSecure {
                revealSecureFieldButton
            } else if !disableEdition {
                clearFieldButton
            }
        } else {
            trailingAccessory
                .transition(.scale.combined(with: .opacity))
        }
    }

    private var clearFieldButton: some View {
        Button(action: { text = "" }) {
            Image.ds.feedback.fail.filled
                .renderingMode(.template)
                .resizable()
                .symbolVariant(.fill)
                .symbolVariant(.circle)
                .foregroundColor(.ds.text.brand.standard)
                .frame(width: accessoryActionDimension, height: accessoryActionDimension)
        }
        .frame(width: accessoryActionTapAreaDimension, height: accessoryActionTapAreaDimension, alignment: .trailing)
        .transition(.scale.combined(with: .opacity))
        .accessibilityLabel(L10n.Core.accessibilityClearText)
    }

    private var revealSecureFieldButton: some View {
        Button(action: {
            displaySecureFieldValueInPlainText.toggle()
        }, label: {
            Group {
                if displaySecureFieldValueInPlainText {
                    Image.ds.action.hide.outlined
                        .resizable()
                } else {
                    Image.ds.action.reveal.outlined
                        .resizable()
                }
            }
            .foregroundColor(.ds.text.brand.standard)
            .frame(width: accessoryActionDimension, height: accessoryActionDimension)
        })
        .frame(width: accessoryActionTapAreaDimension, height: accessoryActionTapAreaDimension, alignment: .trailing)
        .transition(.scale.combined(with: .opacity))
    }

    private var displaySecureField: Bool {
        isSecure && !displaySecureFieldValueInPlainText
    }

    private var displayPlainField: Bool {
        !isSecure || displaySecureFieldValueInPlainText
    }

    private var isFocused: Bool {
        focusedField != nil
    }
}

private extension Color {

    static func focusBorderColor(isFocused: Bool, intensity: Intensity) -> Color {
        switch intensity {
        case .quiet, .catchy:
            return isFocused ? .accentColor.opacity(0.6) : .clear
        case .supershy:
            return .clear
        }
    }

    static func backgroundColor(intensity: Intensity, colorScheme: ColorScheme) -> Color {
        switch intensity {
        case .catchy, .quiet:
            return colorScheme == .light ? Color.white : .ds.container.agnostic.neutral.standard
        case .supershy:
            return .clear
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {

    private struct Preview: View {

        enum FocusedField {
            case login
            case masterPassword
            case typeAnything
        }

        @FocusState private var focusedField: FocusedField?
        @State private var login = "_"
        @State private var masterPassword = ""
        @State private var text = ""

        var body: some View {
            VStack(spacing: 20) {
                TextInput("Email Address", text: $login)
                    .focused($focusedField, equals: .login)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputLabel("Login")
                TextInput("Master Password", text: $masterPassword) {
                    Button("Forgot?") {}
                        .lineLimit(1)
                }
                .focused($focusedField, equals: .masterPassword)
                .textInputIsSecure(true)
                TextInput("Type Anything!", text: $text)
                    .focused($focusedField, equals: .typeAnything)
                    .style(intensity: .quiet)
                    .textInputLabel("Quiet")
                TextInput("Type Anything!", text: $text)
                    .focused($focusedField, equals: .typeAnything)
                    .style(intensity: .supershy)
                    .textInputLabel("Supershy")
            }
            .padding()
            .backgroundColorIgnoringSafeArea(Color(uiColor: .secondarySystemBackground))
        }
    }

    static var previews: some View {
        GenericPropertiesConfiguratorView {
            Preview()
        }
        .padding()
        .ignoresSafeArea([.keyboard], edges: .bottom)
    }
}
#endif
