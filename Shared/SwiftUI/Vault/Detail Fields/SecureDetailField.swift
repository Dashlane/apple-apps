import SwiftUI
import UIDelight
import SwiftTreats
import UIComponents
import VaultKit

typealias Action = (_ fieldType: DetailFieldType) -> Void

extension String: ReferenceConvertible {
    public typealias ReferenceType = NSString
}

struct SecureDetailField: DetailField {

    let title: String
    let placeholderColor: UIColor?

    @Binding
    var text: String

    @Binding
    var shouldReveal: Bool

    @State
    var isFocused: Bool = false

    @Environment(\.detailMode)
    var detailMode

    @Environment(\.detailFieldType)
    var fiberFieldType
    
    let action: Action

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

    init(title: String,
         placeholderColor: UIColor? = nil,
         text: Binding<String>,
         shouldReveal: Binding<Bool>,
         hasDisplayEmptyIndicator: Bool = true,
         formatter: Formatter? = nil,
         obfuscatingFormatter: Formatter? = nil,
         action: @escaping Action,
         usagelogSubType: UsageLog75SubType? = nil,
         isColored: Bool = false) {
        self.title = title
        self.placeholderColor = placeholderColor
        self._text = text
        self._shouldReveal = shouldReveal
        self.hasDisplayEmptyIndicator = hasDisplayEmptyIndicator
        self.formatter = formatter
        self.obfuscatingFormatter = obfuscatingFormatter
        self.action = action
        self.isColored = isColored
    }

    var body: some View {
        HStack {
            if !detailMode.isEditing {
                textfield
            } else if !Device.isMac {
                textfield
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.isFocused = true
                    }
            } else {
                textfield
            }

            if detailMode != .limitedViewing {
                if !text.isEmpty {
                    Toggle(isOn: $shouldReveal) {
                        EmptyView()
                    }.toggleStyle(RevealToggleStyle(fieldType: fiberFieldType, action: action))
                }
            }
        }
        .animation(Device.isMac ? .none : .default, value: shouldReveal)
    }

    var textfield: some View {
        ZStack {
            if !detailMode.isEditing && shouldReveal && isColored {
                PasswordText(text: text, formatter: formatter)
            } else if detailMode.isEditing || (!shouldReveal && obfuscatingFormatter == nil) {
                PasswordField(title, text: $text, isFocused: $isFocused)
                    .passwordFieldSecure(!shouldReveal)
                    .textInputAutocapitalization(.never)
                    .passwordFieldMonospacedFont(true)
                    .disabled(shouldBeDisabled)
                    .fiberAccessibilityHint(!shouldBeDisabled ?  Text(L10n.Localizable.detailItemViewAccessibilityEditableHint) : Text(""))
            }
            else {
                Text("\(text, formatter: effectiveFormatter)")
                    .font(Font.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        .padding(1)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
        .labeled(title)
        .fiberAccessibilityElement(children: .combine)
    }

}

struct PasswordText: View {
    
    var text: String
    let formatter: Formatter?
    
    init(text: String, formatter: Formatter? = nil) {
        self.text = text
        self.formatter = formatter
    }
    
    var body: some View {
        text.reduce(Text(""), { (currentText,char) -> Text in
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
    let action: Action

    private func image(for configuration: Self.Configuration) -> Image {
        return Image(asset: configuration.isOn ? FiberAsset.revealButtonSelected : FiberAsset.revealButton)
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        image(for: configuration)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .fiberAccessibilityLabel(Text(configuration.isOn ? L10n.Localizable.kwHide : L10n.Localizable.kwReveal))
            .foregroundColor(Color(asset: FiberAsset.accentColor))
            .extendTappableArea()
            .animation(nil, value: configuration.isOn)
            .onTapGesture {
                self.action(self.fieldType)
        }
    }
}

extension View {
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
}

struct SecureDetailField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            Group {
                SecureDetailField(title: "Title", text: .constant("test"), shouldReveal: .constant(false), action: {_ in})
                SecureDetailField(title: "Title", text: .constant("test"), shouldReveal: .constant(true), action: {_ in}).environment(\.detailMode, .updating)
                SecureDetailField(title: "Title", text: .constant(""), shouldReveal: .constant(false), action: {_ in})
            }.background(Color(asset: FiberAsset.mainBackground))

        }
        .previewLayout(.sizeThatFits)
    }
}
