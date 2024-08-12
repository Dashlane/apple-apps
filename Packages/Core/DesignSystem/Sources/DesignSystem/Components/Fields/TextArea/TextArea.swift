import SwiftUI

public struct TextArea<FeedbackAccessory: View>: View {
  private let label: String
  private let placeholder: String?
  private let text: Binding<String>
  private let feedbackAccessory: FeedbackAccessory

  public init(
    _ label: String,
    placeholder: String? = nil,
    text: Binding<String>,
    @ViewBuilder feedback: () -> FeedbackAccessory
  ) {
    self.label = label
    self.placeholder = placeholder
    self.text = text
    self.feedbackAccessory = feedback()
  }

  public init(
    _ label: String,
    placeholder: String? = nil,
    text: Binding<String>
  ) where FeedbackAccessory == EmptyView {
    self.label = label
    self.placeholder = placeholder
    self.text = text
    self.feedbackAccessory = EmptyView()
  }

  public var body: some View {
    TextInput(
      label,
      placeholder: placeholder,
      text: text.wrappedValue
    ) {
      TextAreaInputView(label: label, placeholder: placeholder, text: text)
    } actions: {
      EmptyView()
    } feedback: {
      feedbackAccessory
    }
    .actionlessField()
  }
}

private struct PreviewContent: View {
  @State private var notes1 = ""
  @State private var notes2 = ""
  @State private var notes3 =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
  @State private var notes4 =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
  @State private var notes5 = ""

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        TextArea("Notes 1", text: $notes1) {
          FieldTextualFeedback("Please write anything you want here.")
        }
        TextArea("Notes 2", text: $notes2) {
          FieldTextualFeedback("Error feedback.")
        }
        .style(.error)
        TextArea("Notes 3", text: $notes3) {
          FieldTextualFeedback("Be creative!")
        }
        .style(.positive)
        TextArea("Notes 3", text: $notes3) {
          FieldTextualFeedback("Be creative!")
        }
        .style(.positive)
        .disabled(true)
        TextArea("Notes 4", text: $notes4) {
          EmptyView()
        }
        .editionDisabled()
        TextArea("Edge Case", text: $notes4)
          .fieldAppearance(.grouped)
        TextArea("Notes with Placeholder", placeholder: "Placeholder", text: $notes5)
      }
      .frame(maxHeight: .infinity, alignment: .top)
      .padding()
    }
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }
}

#Preview {
  PreviewContent()
}
