import CoreLocalization
import SwiftUI

public struct DesignSystemTextField<ActionsContent: View, FeedbackAccessory: View>: View {
  public typealias Action = FieldAction

  @Environment(\.container) private var container
  @Environment(\.fieldEditionDisabled) private var editionDisabled
  @Environment(\.fieldRequired) private var isRequired

  private let label: String
  private let placeholder: String?
  private let value: Binding<String>
  private let actionsContent: ActionsContent
  private let feedbackAccessory: FeedbackAccessory

  public var body: some View {
    TextInput(
      label,
      placeholder: placeholder,
      text: value.wrappedValue
    ) {
      if editionDisabled && !value.wrappedValue.isEmpty {
        TextInputReadOnlyValueView(value.wrappedValue)
      } else {
        TextFieldInputView(
          label: label,
          placeholder: placeholder,
          value: value
        )
      }
    } actions: {
      actionsContent
    } feedback: {
      feedbackAccessory
    }
    .defaultFieldActionsHidden(ActionsContent.self == EmptyView.self)
  }
}

extension DesignSystemTextField {
  public init(
    _ label: String,
    placeholder: String? = nil,
    text: Binding<String>,
    @ViewBuilder actions: () -> ActionsContent,
    @ViewBuilder feedback: () -> FeedbackAccessory
  ) {
    self.label = label
    self.placeholder = placeholder
    self.value = text
    self.actionsContent = actions()
    self.feedbackAccessory = feedback()
  }

  public init(
    _ label: String,
    placeholder: String? = nil,
    text: Binding<String>,
    @ViewBuilder actions: () -> ActionsContent
  ) where FeedbackAccessory == EmptyView {
    self.label = label
    self.placeholder = placeholder
    self.value = text
    self.actionsContent = actions()
    self.feedbackAccessory = EmptyView()
  }

  public init(
    _ label: String,
    placeholder: String? = nil,
    text: Binding<String>,
    @ViewBuilder feedback: () -> FeedbackAccessory
  ) where ActionsContent == EmptyView {
    self.label = label
    self.placeholder = placeholder
    self.value = text
    self.actionsContent = EmptyView()
    self.feedbackAccessory = feedback()
  }

  public init(
    _ label: String,
    placeholder: String? = nil,
    text: Binding<String>
  ) where ActionsContent == EmptyView, FeedbackAccessory == EmptyView {
    self.label = label
    self.placeholder = placeholder
    self.value = text
    self.actionsContent = EmptyView()
    self.feedbackAccessory = EmptyView()
  }
}

#Preview("Standalone") {
  TextFieldPreview()
    .ignoresSafeArea([.keyboard], edges: .bottom)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
}

#Preview("Grouped") {
  GroupedTextFieldPreview()
    .ignoresSafeArea([.keyboard], edges: .bottom)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
}
