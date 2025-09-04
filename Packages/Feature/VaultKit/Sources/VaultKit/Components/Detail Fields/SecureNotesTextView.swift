import MarkdownUI
import SwiftUI
import UIDelight
import UIKit

public struct SecureNotesTextView: View {

  @Binding
  var text: String
  let placeholder: String
  let isSelectable: Bool
  let isEditable: Bool
  @Binding
  var showLivePreview: Bool

  @State
  var height: CGFloat?

  public init(
    text: Binding<String>,
    placeholder: String = "",
    isEditable: Bool,
    isSelectable: Bool = true,
    showLivePreview: Binding<Bool>
  ) {
    self._text = text
    self.placeholder = placeholder
    self.isEditable = isEditable
    self.isSelectable = isSelectable
    self._showLivePreview = showLivePreview
  }

  public var body: some View {
    VStack {
      if isEditable {
        TextEditor(text: $text)
          .onDisappear {
            showLivePreview = false
          }
        if showLivePreview {
          VStack(alignment: .leading) {
            Divider()
            ScrollView {
              Markdown(text)
                .lineLimit(nil)
            }
          }.transition(.move(edge: .bottom))
        }
      } else {
        if showLivePreview {
          ScrollView {
            Markdown(text)
              .lineLimit(nil)
              .frame(maxWidth: .infinity, alignment: .leading)
              .textSelection(.enabled)
          }.animation(.default, value: showLivePreview)
        } else {
          DynamicHeightTextView(
            text: $text,
            isEditable: isEditable,
            isSelectable: isSelectable,
            placeholder: placeholder,
            $height
          )
          .frame(minHeight: height, alignment: .top)
        }
      }
    }.animation(.default, value: showLivePreview)
  }
}

struct SecureNotesTextView_preview: PreviewProvider {
  static var previews: some View {
    SecureNotesTextView(
      text: .constant(
        "Hello, **SwiftUI** ! \nWe can make text *italic*, ***bold italic***, or ~~striked through~~.\n_Or use `Monospace` to mimic `Text(\"inline code\")`."
      ),
      placeholder: "",
      isEditable: false,
      isSelectable: true,
      showLivePreview: .constant(false))

    SecureNotesTextView(
      text: .constant(
        "Hello, **SwiftUI** ! \nWe can make text *italic*, ***bold italic***, or ~~striked through~~.\n_Or use `Monospace` to mimic `Text(\"inline code\")`."
      ),
      placeholder: "",
      isEditable: true,
      isSelectable: true,
      showLivePreview: .constant(true))
  }

}
