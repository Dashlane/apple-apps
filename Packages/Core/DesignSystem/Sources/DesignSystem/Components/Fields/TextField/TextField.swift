import CoreLocalization
import SwiftUI

public struct DesignSystemTextField<ActionsContent: View, FeedbackAccessory: View>: View {
  public typealias Action = FieldAction

  @Environment(\.fieldAppearance) private var appearance
  @Environment(\.editionDisabled) private var editionDisabled
  @Environment(\.textInputDisabledEditionAppearance) private var disabledEditionAppearance

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
    .actionlessField(ActionsContent.self == EmptyView.self)
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
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
}

#Preview("Grouped") {
  GroupedTextFieldPreview()
    .ignoresSafeArea([.keyboard], edges: .bottom)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
}
