import CoreLocalization
import SwiftUI

struct DetailFieldContainer<FieldContent: View, Actions: View>: View {

  let label: String
  let content: FieldContent
  let actions: Actions

  @Environment(\.fieldLabelHiddenOnFocus) private var isLabelDisabled
  @Environment(\.displayLabelAsOverlay) var displayLabelAsOverlay
  @Environment(\.fieldRequired) private var isRequired
  @Environment(\.defaultFieldActionsHidden) private var defaultFieldActionsHidden
  @Environment(\.isFieldEditing) private var isFieldEditing
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.style.mood) private var mood
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  private var isAccessibilitySize: Bool {
    dynamicTypeSize.isAccessibilitySize
  }

  @ScaledMetric private var contentHeight: CGFloat = 34
  @ScaledMetric private var minimumHeight = 48
  @ScaledMetric private var contentTrailingPadding = 4
  private var labelHeight: CGFloat = 17

  init(
    _ label: String,
    isEditing: Bool = false,
    @ViewBuilder content: @escaping () -> FieldContent,
    @ViewBuilder actions: @escaping () -> Actions
  ) {
    self.label = label
    self.content = content()
    self.actions = actions()
  }

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      ZStack {
        content
          .frame(maxWidth: .infinity, minHeight: contentHeight, alignment: .leading)
          .padding(.trailing, contentTrailingPadding)
          .padding(.top, isLabelDisabled ? 0 : labelHeight)
          .overlay(labelView, alignment: .leading)
          #if os(iOS)
            .sensoryFeedback(trigger: isFieldEditing) { wasFocused, isFocused in
              return (isFocused && wasFocused == false)
                ? .impact(flexibility: .soft, intensity: 0.5) : nil
            }
          #endif
      }
      .accessibilityElement(children: .combine)

      if isEnabled {
        actionsContainer
      }
    }
    .listRowInsets(EdgeInsets.field(isLabelVisible: !isLabelDisabled))
    .frame(minHeight: minimumHeight - EdgeInsets.field(isLabelVisible: !isLabelDisabled).vertical)
    .tint(.fieldTintColor(for: mood))
    .transformEnvironment(\.style) { style in
      style = Style(mood: style.mood, intensity: .quiet, priority: style.priority)
    }
    .transformEnvironment(\.dynamicTypeSize) { typeSize in
      guard dynamicTypeSize > .accessibility2 else { return }
      typeSize = .accessibility2
    }
  }

  private var actionsContainer: some View {
    FieldActionsStack {
      actions
    }
    .tint(.fieldTintColor(for: .brand))
    .transformEnvironment(\.style) { style in
      style = .init(mood: .brand, intensity: .quiet, priority: .high)
    }
  }

  @ViewBuilder
  private var labelView: some View {
    ZStack {
      if isLabelDisabled, displayLabelAsOverlay {
        Text(label + (isRequired ? "*" : ""))
          .textStyle(
            displayLabelAsOverlay
              ? .body.standard.regular
              : .body.helper.regular
          )
          .foregroundStyle(.label(isFocused: isFieldEditing))
          .multilineTextAlignment(.leading)
          .minimumScaleFactor(isAccessibilitySize ? 0.6 : 0.8)
          .allowsHitTesting(false)
          .transition(.opacity.combined(with: .offset(y: -labelHeight)))
          .accessibilityLabel(accessibilityLabel)
          .accessibilitySortPriority(1)
      } else {
        LabelContainer(isReduced: !displayLabelAsOverlay) {
          Text(label + (isRequired ? "*" : ""))
            .textStyle(
              displayLabelAsOverlay
                ? .body.standard.regular
                : .body.helper.regular
            )
            .foregroundStyle(.label(isFocused: isFieldEditing))
            .multilineTextAlignment(.leading)
            .allowsHitTesting(false)
            .opacity(isLabelDisabled ? 0 : 1)
            .accessibilityLabel(accessibilityLabel)
            .accessibilitySortPriority(1)
        }
      }
    }
    .animation(.spring(response: 0.3, dampingFraction: 1), value: displayLabelAsOverlay)
    .transformEnvironment(\.style) { style in
      style = Style(mood: style.mood, intensity: .supershy, priority: style.priority)
    }
  }

  private var accessibilityLabel: Text {
    if isRequired {
      return Text("\(label), \(CoreL10n.textInputRequired)")
    }
    return Text("\(label)")
  }

  private var hasActions: Bool {
    return !defaultFieldActionsHidden
  }
}

extension Color {
  fileprivate static func fieldTintColor(for mood: Mood) -> Color {
    if mood == .danger {
      return .ds.text.danger.standard
    } else {
      return .ds.text.brand.standard
    }
  }
}

#Preview {
  List {
    DetailFieldContainer("Label") {
      Text("Field content long text")
    } actions: {
      DS.FieldAction.CopyContent { print("Copy action.") }
    }

    DetailFieldContainer("Label") {
      HStack {
        Circle()
          .fill(.green)
          .frame(width: 12)
        Text("Green")
      }
    } actions: {
    }
  }
  .listStyle(.insetGrouped)
}
