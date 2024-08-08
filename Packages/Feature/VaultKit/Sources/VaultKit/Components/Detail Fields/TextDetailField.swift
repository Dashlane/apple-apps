import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct TextDetailField: DetailField {
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
  let placeholder: String

  @Binding
  var text: String

  let actions: [Action]

  @Environment(\.detailMode)
  var detailMode

  @Environment(\.detailFieldType)
  public var fiberFieldType

  public init(
    title: String,
    text: Binding<String>,
    placeholder: String = "",
    actions: [Action] = []
  ) {
    self.title = title
    self._text = text
    self.placeholder = placeholder
    self.actions = actions
  }

  @ViewBuilder
  public var body: some View {
    textField
      .contentShape(Rectangle())
  }

  var textField: some View {
    DS.TextField(
      title, placeholder: placeholder, text: $text,
      actions: {
        ForEach(actions, id: \.id) { action in
          switch action {
          case .copy(let action):
            if !text.isEmpty {
              DS.FieldAction.CopyContent { action(text, fiberFieldType) }
            }
          case .other(let title, let image, let action):
            DS.FieldAction.Button(title, image: image, action: action)
          }
        }
      }
    )
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled()
    .lineLimit(1)
    .frame(maxWidth: .infinity)
    .fiberAccessibilityHint(
      detailMode.isEditing ? Text(L10n.Core.detailItemViewAccessibilityEditableHint) : Text(""))
  }
}

struct TextDetailField_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      VStack {
        TextDetailField(title: "Title", text: .constant("test")).environment(\.detailMode, .viewing)
        TextDetailField(title: "Title", text: .constant("test")).environment(
          \.detailMode, .updating)
        TextDetailField(title: "Title", text: .constant("")).environment(\.detailMode, .viewing)
        TextDetailField(title: "Title", text: .constant("")).environment(\.detailMode, .updating)
      }
      .background(Color.ds.background.default)
    }.previewLayout(.sizeThatFits)
  }
}
