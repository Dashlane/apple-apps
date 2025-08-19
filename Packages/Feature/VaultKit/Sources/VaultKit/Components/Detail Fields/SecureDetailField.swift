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

  let format: FieldValueFormat?

  var shouldBeDisabled: Bool {
    return !detailMode.isEditing
  }

  public init(
    title: String,
    text: Binding<String>,
    onRevealAction: OnRevealAction? = nil,
    format: FieldValueFormat? = nil,
    actions: [Action] = [],
    feedback: FeedbackContent?
  ) {
    self.title = title
    self._text = text
    self.onRevealAction = onRevealAction
    self.format = format
    self.actions = actions
    self.feedback = feedback
  }

  public init(
    title: String,
    text: Binding<String>,
    onRevealAction: OnRevealAction? = nil,
    format: FieldValueFormat? = nil,
    actions: [Action] = []
  ) where FeedbackContent == EmptyView {
    self.init(
      title: title,
      text: text,
      onRevealAction: onRevealAction,
      format: format,
      actions: actions,
      feedback: EmptyView()
    )
  }

  @ViewBuilder
  public var body: some View {
    if !Device.is(.mac) && detailMode.isEditing {
      textfield
        .lineLimit(1)
        .frame(maxWidth: .infinity)
        .environment(\.editMode, detailMode.isEditing ? .constant(.active) : .constant(.inactive))
        .contentShape(Rectangle())
        .onTapGesture {
          self.isFocused = true
          self.isFocusedBinding = true
        }
    } else {
      textfield
        .lineLimit(1)
        .frame(maxWidth: .infinity)
        .environment(\.editMode, detailMode.isEditing ? .constant(.active) : .constant(.inactive))
    }
  }

  @ViewBuilder
  var textfield: some View {
    if let format {
      if detailMode.isEditing {
        dsObfuscatedInputField
      } else {
        dsObfuscatedDisplayField(format: format)
      }
    } else {
      dsPasswordField
    }
  }

  private var dsPasswordField: some View {
    DS.PasswordField(
      title,
      text: $text,
      shouldReveal: detailMode.isAdding,
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
      },
      feedback: {
        if let feedback {
          feedback
        }
      }
    )
    .onRevealSecureValue { onRevealAction?(fiberFieldType) }
    .focused($isFocused)
    .fiberAccessibilityHint(
      !shouldBeDisabled ? Text(CoreL10n.detailItemViewAccessibilityEditableHint) : Text(""))
  }

  private var dsObfuscatedInputField: some View {
    DS.ObfuscatedInputField(
      title,
      text: $text,
      shouldReveal: detailMode.isAdding,
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
    .onRevealSecureValue { onRevealAction?(fiberFieldType) }
    .focused($isFocused)
    .fiberAccessibilityHint(
      !shouldBeDisabled ? Text(CoreL10n.detailItemViewAccessibilityEditableHint) : Text(""))
  }

  private func dsObfuscatedDisplayField(format: FieldValueFormat) -> some View {
    DS.ObfuscatedDisplayField(title, value: text, format: format) {
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
    .onRevealSecureValue { onRevealAction?(fiberFieldType) }
    .focused($isFocused)
    .fiberAccessibilityHint(
      !shouldBeDisabled ? Text(CoreL10n.detailItemViewAccessibilityEditableHint) : Text(""))
  }

}

#Preview("Password fields - Default") {
  SecureDetailField(title: "Title", text: .constant("test"))
    .background(Color.ds.background.default)
}

#Preview("Password fields - Updating") {
  SecureDetailField(title: "Title", text: .constant("test"))
    .environment(\.detailMode, .updating)
    .background(Color.ds.background.default)
}

#Preview("Password fields - Empty") {
  SecureDetailField(title: "Title", text: .constant(""))
    .background(Color.ds.background.default)
}

#Preview("Formatted fields - Card Number") {
  SecureDetailField(title: "Title", text: .constant("1234222233334444"), format: .cardNumber)
    .background(Color.ds.background.default)
}

#Preview("Formatted fields - BIC") {
  SecureDetailField(
    title: "Title", text: .constant("BARCGB22XXX"), format: .accountIdentifier(.bic)
  )
  .background(Color.ds.background.default)
}

#Preview("Formatted fields - Obfuscated Note") {
  SecureDetailField(title: "Title", text: .constant("Test note"), format: .obfuscated(maxLength: 4))
    .background(Color.ds.background.default)
}
