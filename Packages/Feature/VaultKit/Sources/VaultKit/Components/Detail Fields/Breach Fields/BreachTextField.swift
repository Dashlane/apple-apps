import DesignSystem
import Foundation
import SwiftUI
import UIComponents
import UIDelight

public struct BreachTextField: DetailField {
  public let title: String

  @Binding
  var text: String

  @FocusState
  var isFocused: Bool

  @Environment(\.detailFieldType)
  public var fiberFieldType

  let isUserInteractionEnabled: Bool

  public init(
    title: String,
    text: Binding<String>,
    isUserInteractionEnabled: Bool = true
  ) {
    self.title = title
    self._text = text
    self.isUserInteractionEnabled = isUserInteractionEnabled
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.footnote)
        .foregroundStyle(Color.ds.text.oddity.disabled)

      textField
        .contentShape(Rectangle())
        .disabled(!isUserInteractionEnabled)
        .onTapGesture {
          self.isFocused = true
        }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(Color.ds.container.agnostic.neutral.supershy)
  }

  var textField: some View {
    TextField("", text: $text)
      .textInputAutocapitalization(.never)
      .focused($isFocused)
      .autocorrectionDisabled()
      .lineLimit(1)
      .frame(maxWidth: .infinity)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  VStack {
    BreachTextField(title: "Title", text: .constant("test"))
  }
}
