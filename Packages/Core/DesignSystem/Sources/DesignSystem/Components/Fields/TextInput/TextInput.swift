import CoreLocalization
import SwiftUI

struct TextInput<InputView: View, ActionsContent: View, FeedbackAccessory: View>: View {
  public typealias Action = FieldAction

  @Environment(\.style) private var style
  @Environment(\.container) private var container
  @Environment(\.fieldLabelHiddenOnFocus) private var isLabelPersistencyDisabled
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.fieldRequired) private var isRequired
  @Environment(\.fieldEditionDisabled) private var editionDisabled

  @FocusState var isFocused: Bool

  private let label: String
  private let placeholder: String?
  private let text: String
  private let inputView: InputView
  private let actionsContent: ActionsContent
  private let feedbackAccessory: FeedbackAccessory

  private var standaloneHorizontalPadding = 20.0
  private var groupedVerticalPadding = 8.0
  @ScaledMetric private var contentHeight: CGFloat = 34

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
      DetailFieldContainer(label) {
        inputView
          .frame(maxWidth: .infinity, minHeight: contentHeight, alignment: .leading)
          .contentShape(Rectangle())
          .focused($isFocused)
          .onTapGesture {
            isFocused = true
          }
          .allowsHitTesting(!editionDisabled || isFocused)
      } actions: {
        actionsContent
      }
      .padding(effectiveInputAreaContainerPaddings)
      .focused($isFocused)
      .environment(\.displayLabelAsOverlay, !isFocused && text.isEmpty)
      .environment(\.isFieldEditing, isFocused)
      .background(TextInputBackground(isFocused: isFocused))

      TextInputFeedbackContainer {
        feedbackAccessory
          .padding(.horizontal, effectiveInputAreaContainerPaddings.leading)
      }
    }
    .listRowInsets(EdgeInsets.field(isLabelVisible: !isLabelPersistencyDisabled))
  }

  private var isGrouped: Bool {
    if case .list(.insetGrouped) = container {
      true
    } else {
      false
    }
  }

  private var effectiveInputAreaContainerPaddings: EdgeInsets {
    let leading: Double = isGrouped ? 0 : 16

    let vertical: Double = isGrouped ? 0 : 4

    return EdgeInsets(
      top: vertical,
      leading: leading,
      bottom: vertical,
      trailing: 0
    )
  }
}

#Preview("Standalone") {
  TextFieldPreview()
    .padding()
    .ignoresSafeArea([.keyboard], edges: .bottom)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
}

#Preview("Grouped") {
  GroupedTextFieldPreview()
    .ignoresSafeArea([.keyboard], edges: .bottom)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
}
