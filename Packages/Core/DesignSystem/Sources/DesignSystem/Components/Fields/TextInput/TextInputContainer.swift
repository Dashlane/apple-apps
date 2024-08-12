import SwiftUI
import UIDelight

struct TextInputContainer<InputView: View, ActionsContent: View>: View {
  typealias Action = FieldAction

  @Environment(\.style.mood) private var mood
  @Environment(\.fieldAppearance) private var appearance
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.fieldLabelPersistencyDisabled) private var isLabelPersistencyDisabled
  @Environment(\.editionDisabled) private var editionDisabled
  @Environment(\.dynamicTypeSize.isAccessibilitySize) private var isAccessibilitySize
  @Environment(\.isFieldActionless) private var isFieldActionless

  @State private var isLabelAtEndPosition = false

  @ScaledMetric private var minimumHeight = 48
  @ScaledMetric private var areaContainerLeadingPadding = 16
  @ScaledMetric private var areaContainerTrailingPadding = 16
  @ScaledMetric private var actionsContainerHorizontalPadding = 4
  @ScaledMetric private var verticalContainerPadding = 4
  @ScaledMetric private var nonPersistentLabelTransitionVerticalOffset = -14
  @ScaledMetric private var inputAreaContainerSpacing = 2
  @ScaledMetric private var bottomPadding = 4

  private let label: String
  private let placeholder: String?
  private let text: String
  private let inputView: InputView
  private let actionsContent: ActionsContent

  @FocusState private var isFocused

  init(
    _ label: String,
    placeholder: String?,
    text: String,
    @ViewBuilder inputView: () -> InputView,
    @ViewBuilder actionsContent: () -> ActionsContent
  ) {
    self.label = label
    self.placeholder = placeholder
    self.text = text
    self.inputView = inputView()
    self.actionsContent = actionsContent()
    _isLabelAtEndPosition = .init(initialValue: !text.isEmpty)
  }

  var body: some View {
    HStack(spacing: 0) {
      inputAreaContainer
      actionsContainer
    }
    .padding(effectivePaddings)
    .background(TextInputBackground(isFocused: isFocused))
  }

  private var inputAreaContainer: some View {
    VStack(alignment: .leading, spacing: inputAreaContainerSpacing) {
      if !isLabelPersistencyDisabled {
        smallLabelView
      }
      inputView
        .focused($isFocused)
    }
    .overlay(labelView, alignment: .leading)
    .frame(maxWidth: .infinity, minHeight: minimumHeight, alignment: .leading)
    .allowsHitTesting(isFocused)
    .padding(effectiveInputAreaContainerPaddings)
    .contentShape(Rectangle())
    .onTapGesture {
      if !isFocused {
        performHapticFeedback()
      }
      isFocused = true
    }
    .allowsHitTesting(!shouldDisableInteractivity)
    .onChange(of: isFocused) { isFocused in
      guard text.isEmpty else { return }
      moveLabel(toEndPosition: isFocused)
    }
    .onChange(of: text) { text in
      guard !isFocused else { return }
      moveLabel(toEndPosition: !text.isEmpty)
    }
    .onChange(of: editionDisabled) { editionDisabled in
      moveLabel(toEndPosition: editionDisabled || !text.isEmpty)
    }
  }

  private var actionsContainer: some View {
    FieldActionsStack {
      actionsContent
    }
    .padding(.horizontal, effectiveActionsContainerHorizontalPadding)
  }

  private var smallLabelView: some View {
    FieldSmallLabel(label)
      .hidden()
      .accessibilityHidden(true)
  }

  @ViewBuilder
  private var labelView: some View {
    ZStack {
      if isLabelPersistencyDisabled, !isLabelAtEndPosition {
        Text(label)
          .textStyle(
            isLabelAtEndPosition
              ? .body.helper.regular
              : .body.standard.regular
          )
          ._foregroundStyle(.label(isFocused: isFocused))
          .animation(.easeInOut(duration: 0.2), value: isFocused)
          .multilineTextAlignment(.leading)
          .minimumScaleFactor(isAccessibilitySize ? 0.6 : 0.8)
          .allowsHitTesting(false)
          .transition(
            .opacity.combined(
              with: .offset(y: nonPersistentLabelTransitionVerticalOffset)
            )
          )
          .accessibilityHidden(true)
      } else {
        LabelContainer(isReduced: isLabelAtEndPosition) {
          Text(label)
            .textStyle(
              isLabelAtEndPosition
                ? .body.helper.regular
                : .body.standard.regular
            )
            ._foregroundStyle(.label(isFocused: isFocused))
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .multilineTextAlignment(.leading)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .opacity(isLabelPersistencyDisabled ? 0 : 1)
        }
      }
    }
    .transformEnvironment(\.style) { style in
      style = Style(mood: style.mood, intensity: .supershy, priority: style.priority)
    }
  }

  private func moveLabel(toEndPosition endPosition: Bool) {
    guard endPosition != isLabelAtEndPosition else { return }
    withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
      isLabelAtEndPosition = endPosition
    }
  }

  private var effectivePaddings: EdgeInsets {
    var bottom: Double {
      guard !isGrouped, isAccessibilitySize else { return 0 }
      return hasActions ? bottomPadding : 0
    }

    var trailing: Double {
      guard isGrouped, hasActions, !isAccessibilitySize else { return 0 }
      return -areaContainerTrailingPadding
    }

    return EdgeInsets(top: 0, leading: 0, bottom: bottom, trailing: trailing)
  }

  private var effectiveInputAreaContainerPaddings: EdgeInsets {
    var leading: Double {
      guard !isGrouped else { return 0 }
      return areaContainerLeadingPadding
    }

    var vertical: Double {
      if isGrouped { return 0 }
      return verticalContainerPadding
    }

    var trailing: Double {
      guard !isGrouped, !hasActions else { return 0 }
      return areaContainerTrailingPadding
    }

    return EdgeInsets(
      top: vertical,
      leading: leading,
      bottom: vertical,
      trailing: trailing
    )
  }

  private var effectiveActionsContainerHorizontalPadding: Double {
    guard hasActions else { return 0 }
    return actionsContainerHorizontalPadding
  }

  private func performHapticFeedback() {
    #if canImport(UIKit)
      UIImpactFeedbackGenerator.softImpactGenerator.impactOccurred(intensity: 0.5)
    #endif
  }

  private var isGrouped: Bool {
    if case .grouped = appearance { return true }
    return false
  }

  private var shouldDisableInteractivity: Bool {
    return editionDisabled
  }

  private var hasActions: Bool {
    return !isFieldActionless
  }

  private var accessibilityLabel: Text {
    if text.isEmpty {
      let texts = [label, placeholder].compactMap { $0 }
      return Text(texts.joined(separator: ","))
    } else {
      return Text("\(label), \(text)")
    }
  }
}

private struct LabelShapeStyle: ShapeStyle, ShapeStyleColorResolver {
  private let isFocused: Bool

  init(isFocused: Bool) {
    self.isFocused = isFocused
  }

  func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
    resolvedColor(in: environment)
  }

  func resolvedColor(in environment: EnvironmentValues) -> Color {
    TextShapeStyle { _, color in
      guard environment.style.mood == .brand && !isFocused && environment.isEnabled
      else { return color }
      return .ds.text.neutral.quiet
    }
    .resolvedColor(in: environment)
  }
}

extension ShapeStyle where Self == LabelShapeStyle {
  fileprivate static func label(isFocused: Bool) -> Self {
    LabelShapeStyle(isFocused: isFocused)
  }
}

private struct LabelContainer: Layout {
  let isReduced: Bool

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    return CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    guard let labelView = subviews.first else { return }
    let size = labelView.dimensions(in: proposal)
    let origin = CGPoint(
      x: bounds.origin.x,
      y: isReduced
        ? bounds.minY + (size.height / 2)
        : bounds.midY
    )
    labelView.place(at: origin, anchor: .leading, proposal: proposal)
  }
}

#if canImport(UIKit)
  extension UIImpactFeedbackGenerator {
    fileprivate static let softImpactGenerator = UIImpactFeedbackGenerator(style: .soft)
  }
#endif

#Preview {
  TextInputContainer(
    "Label",
    placeholder: "Placeholder",
    text: "Value",
    inputView: { EmptyView() },
    actionsContent: { EmptyView() }
  )
  .actionlessField()
  .padding(.horizontal, 40)
  .backgroundColorIgnoringSafeArea(.ds.background.alternate)
}
