import CoreLocalization
import SwiftUI

struct TextInput<InputView: View, ActionsContent: View, FeedbackAccessory: View>: View {
  public typealias Action = FieldAction

  @Environment(\.style) private var style
  @Environment(\.fieldAppearance) private var appearance
  @Environment(\.fieldLabelPersistencyDisabled) private var isLabelPersistencyDisabled
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  private let label: String
  private let placeholder: String?
  private let text: String
  private let inputView: InputView
  private let actionsContent: ActionsContent
  private let feedbackAccessory: FeedbackAccessory

  private var standaloneHorizontalPadding = 16.0
  private var groupedVerticalPadding = 8.0

  init(
    _ label: String,
    placeholder: String? = nil,
    text: String,
    @ViewBuilder inputView: () -> InputView,
    @ViewBuilder actions: () -> ActionsContent,
    @ViewBuilder feedback: () -> FeedbackAccessory
  ) {
    self.label = label
    self.placeholder = placeholder
    self.text = text
    self.inputView = inputView()
    self.actionsContent = actions()
    self.feedbackAccessory = feedback()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      TextInputContainer(
        label,
        placeholder: placeholder,
        text: text,
        inputView: {
          inputView
            .accessibilityElement(children: .contain)
        },
        actionsContent: { actionsContent }
      )
      TextInputFeedbackContainer {
        feedbackAccessory
          .padding(.horizontal, effectiveHorizontalContentPadding)
      }
    }
    .listRowInsets(effectiveListRowInsets)
    .tint(.tintColor(for: style.mood))
    .transformEnvironment(\.style) { style in
      style = Style(mood: style.mood, intensity: .quiet, priority: style.priority)
    }
    .transformEnvironment(\.dynamicTypeSize) { typeSize in
      guard dynamicTypeSize > .accessibility2 else { return }
      typeSize = .accessibility2
    }
  }

  private var effectiveHorizontalContentPadding: Double {
    guard case .standalone = appearance else { return 0 }
    return standaloneHorizontalPadding
  }

  private var effectiveListRowInsets: EdgeInsets? {
    guard appearance == .grouped else { return nil }

    return EdgeInsets(
      top: isLabelPersistencyDisabled ? 0 : groupedVerticalPadding,
      leading: 20,
      bottom: isLabelPersistencyDisabled ? 0 : groupedVerticalPadding,
      trailing: 20
    )
  }

  private var hasActions: Bool {
    ActionsContent.self != EmptyView.self
  }
}

extension Color {

  fileprivate static func tintColor(for mood: Mood) -> Color {
    if mood == .danger {
      return .ds.text.danger.standard
    } else {
      return .ds.text.brand.standard
    }
  }
}

#Preview("Standalone") {
  TextFieldPreview()
    .padding()
    .ignoresSafeArea([.keyboard], edges: .bottom)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
}

#Preview("Grouped") {
  GroupedTextFieldPreview()
    .ignoresSafeArea([.keyboard], edges: .bottom)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
}
