import DesignSystem
import DesignSystemExtra
import SwiftUI
import UIDelight

public struct LostOTPAlertModifier<Buttons: View, Item: Identifiable>: ViewModifier {
  public init(
    item: Binding<Item?>,
    textFieldInput: Binding<String>,
    title: String,
    message: String? = nil,
    placeholder: String,
    isSecure: Bool = false,
    @ViewBuilder buttons: () -> Buttons
  ) {
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

        NativeTextFieldAlert(
          title: title,
          message: message,
          placeholder: placeholder,
          isSecure: isSecure,
          textFieldInput: $textFieldInput
        ) {
          buttons
        }
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
