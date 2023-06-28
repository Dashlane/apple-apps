#if canImport(UIKit)
import SwiftUI
import UIDelight
import DesignSystem

public struct AlertTextFieldModifier<Buttons: View, Item: Identifiable>: ViewModifier {
    public init(item: Binding<Item?>,
                textFieldInput: Binding<String>,
                title: String,
                message: String? = nil,
                placeholder: String,
                isSecure: Bool = false,
                @ViewBuilder buttons: () -> Buttons) {
        self._item = item
        self._textFieldInput = textFieldInput
        self.title = title
        self.message = message
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.buttons = buttons()
    }

    @Binding
    var item: Item?

    @Binding
    var textFieldInput: String

    let title: String
    let message: String?
    let placeholder: String
    let isSecure: Bool

    @ViewBuilder
    var buttons: Buttons

    public func body(content: Content) -> some View {
        if item != nil {
            ZStack {
                content
                    .overlay(backgroundView)
                AlertTextFieldView(title: title,
                                   message: message,
                                   placeholder: placeholder,
                                   isSecure: isSecure,
                                   textFieldInput: $textFieldInput,
                                   buttons: { buttons })
            }
        } else {
            content
        }

    }

    private var backgroundView: some View {
        Color.black
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity)
            .opacity(0.5)
    }
}

public struct AlertTextFieldView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    private let textFieldCornerRadius: Double = 7

    let title: String
    var message: String?
    let placeholder: String
    let isSecure: Bool
    let onSubmit: (() -> Void)?

    @Binding
    var textFieldInput: String

    @ViewBuilder
    var buttons: Content

    @State
    var isTextFieldFocused = false

    public init(title: String,
                message: String? = nil,
                placeholder: String,
                isSecure: Bool,
                textFieldInput: Binding<String>,
                onSubmit: (() -> Void)? = nil,
                buttons: () -> Content) {
        self.title = title
        self.message = message
        self.placeholder = placeholder
        self.onSubmit = onSubmit
        self.isSecure = isSecure
        self._textFieldInput = textFieldInput
        self.buttons = buttons()
    }

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text(title)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    if let message = message {
                        Text(message)
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .padding([.top, .bottom], 4)

                textField
                Divider()
                buttons
                    .buttonStyle(AlertButtonStyle())
                    .frame(maxWidth: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
            .modifier(AlertStyle())
            .onAppear {
                isTextFieldFocused = true
            }
            Spacer()
            KeyboardSpacer()
        }
    }

    private var textField: some View {
        Group {
            if isSecure {
                DS.PasswordField(placeholder, text: $textFieldInput)
            } else {
                DS.TextField(placeholder, text: $textFieldInput)
            }
        }
        .textFieldDisableLabelPersistency()
        .submitLabel(.go)
        .textInputAutocapitalization(.never)
        .textContentType(.oneTimeCode) 
        .autocorrectionDisabled()
        .padding(6)
        .padding([.horizontal, .bottom])
    }
}

struct AlertTextFieldView_Previews: PreviewProvider {
    struct Preview: View {
        @State private var text = ""

        var body: some View {
            AlertTextFieldView(title: "Title",
                               message: "Message",
                               placeholder: "field placeholder",
                               isSecure: false,
                               textFieldInput: $text,
                               buttons: {
                Group {
                    Button("Hello") {
                        print("hello")
                    }
                    Divider()
                    Button("World") {
                        print("world")
                    }
                }
            })
        }
    }
    static var previews: some View {
        Preview()
    }
}
#endif
