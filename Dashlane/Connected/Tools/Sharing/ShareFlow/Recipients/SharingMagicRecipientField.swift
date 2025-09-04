import CoreLocalization
import SwiftUI
import UIComponents

struct SharingMagicRecipientField: View {
  @Binding
  var text: String

  @FocusState
  var isFocused: Bool

  var placeholderText: String

  var body: some View {
    HStack {
      TextField("", text: $text)
        .accessibility(label: Text(placeholderText))
        .background(alignment: .leading) {
          if text.isEmpty {
            Text(placeholderText)
              .foregroundStyle(Color.ds.text.neutral.quiet)
              .accessibilityHidden(true)
          }
        }
        .autocapitalization(.none)
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .focused($isFocused)

      if !text.isEmpty {
        Button {
          text = ""
          isFocused = false
        } label: {
          Image(systemName: "xmark.circle.fill")
            .resizable()
            .frame(width: 16.0, height: 16.0)
        }
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .fiberAccessibilityLabel(Text(CoreL10n.accessibilityClearSearchTextField))
      }
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 10)
    .background(
      Color.ds.container.agnostic.neutral.standard,
      in: RoundedRectangle(cornerRadius: 10, style: .continuous))
  }
}

struct SharingRecipientFilterField_Previews: PreviewProvider {
  static var previews: some View {
    SharingMagicRecipientField(text: .constant(""), placeholderText: "Dashlane email address")
      .previewLayout(.sizeThatFits)
    SharingMagicRecipientField(
      text: .constant("Email"), placeholderText: "Dashlane email address or Group"
    )
    .previewLayout(.sizeThatFits)
  }
}
