import DesignSystem
import SwiftUI

public struct NativeTextFieldAlert<Buttons: View>: View {
  private let textFieldCornerRadius: Double = 7

  let title: String
  var message: String?
  let placeholder: String
  let isSecure: Bool
  let onSubmit: () -> Void

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.displayScale) private var displayScale
  @Binding var textFieldInput: String
  @ViewBuilder let buttons: Buttons
  @FocusState var isTextFieldFocused

  public init(
    title: String,
    message: String? = nil,
    placeholder: String,
    isSecure: Bool,
    textFieldInput: Binding<String>,
    onSubmit: (() -> Void)? = nil,
    @ViewBuilder buttons: () -> Buttons
  ) {
    self.title = title
    self.message = message
    self.placeholder = placeholder
    self.onSubmit = onSubmit ?? {}
    self.isSecure = isSecure
    self._textFieldInput = textFieldInput
    self.buttons = buttons()
  }

  public var body: some View {
    NativeAlert(spacing: 0) {
      VStack(spacing: 6) {
        Text(title)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .multilineTextAlignment(.center)
          .font(.headline)
        if let message = message {
          Text(message)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .multilineTextAlignment(.center)
            .font(.footnote)
            .padding(.horizontal)
        }
      }
      .padding()
      .padding([.top, .bottom], 4)

      textField
    } buttons: {
      buttons
    }
    .fixedSize(horizontal: false, vertical: true)
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity
    )
    .onAppear {
      isTextFieldFocused = true
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
    .focused($isTextFieldFocused)
    .fieldLabelHiddenOnFocus()
    .submitLabel(.go)
    .textInputAutocapitalization(.never)
    .textContentType(.oneTimeCode)
    .autocorrectionDisabled()
    .padding(6)
    .padding([.horizontal, .bottom])
    .onSubmit(onSubmit)
  }
}

#Preview {
  @Previewable @State var text = ""

  NativeTextFieldAlert(
    title: "Title",
    message: "Message",
    placeholder: "field placeholder",
    isSecure: false,
    textFieldInput: $text
  ) {
    Button("Hello") {
      print("hello")
    }
    Button("World") {
      print("world")
    }
  }
}
