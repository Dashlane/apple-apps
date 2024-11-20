import CoreLocalization
import SwiftUI

public struct DisplayField<Content: View, Actions: View>: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.fieldLabelPersistencyDisabled) private var isLabelDisabled
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.lineLimit) private var lineLimit
  @Environment(\.style.mood) private var mood

  @ScaledMetric private var contentTrailingSpacing = 4
  @ScaledMetric private var contentVerticalSpacing = 4
  @ScaledMetric private var horizontalPadding = 4
  @ScaledMetric private var minimumHeight = 48
  @ScaledMetric private var verticalPadding = 8

  @State private var isLabelOverflowing = false

  private let actions: Actions
  private let content: Content
  private let label: String

  public init(
    _ label: String,
    @ViewBuilder content: () -> Content,
    @ViewBuilder actions: () -> Actions
  ) {
    self.label = label
    self.content = content()
    self.actions = actions()
  }

  public init(
    _ label: String,
    text: String,
    @ViewBuilder actions: () -> Actions
  ) where Content == Label<Text, EmptyView> {
    self.label = label
    self.content = Label(
      title: { Text(verbatim: text) },
      icon: { EmptyView() }
    )
    self.actions = actions()
  }

  public init(
    _ label: String,
    text: String
  ) where Content == Label<Text, EmptyView>, Actions == EmptyView {
    self.init(label, text: text) {
      EmptyView()
    }
  }

  public init(
    _ label: String,
    placeholder: String
  ) where Content == _DisplayFieldTextualPlaceholder, Actions == EmptyView {
    self.init(label) {
      _DisplayFieldTextualPlaceholder(placeholder)
    } actions: {
      EmptyView()
    }
  }

  public init(
    _ label: String,
    placeholder: String,
    @ViewBuilder actions: () -> Actions
  ) where Content == _DisplayFieldTextualPlaceholder {
    self.init(label) {
      _DisplayFieldTextualPlaceholder(placeholder)
    } actions: {
      actions()
    }
  }

  public var body: some View {
    HStackLayout(alignment: isLabelOverflowing ? .top : .center, spacing: 0) {
      VStack(alignment: .leading, spacing: contentVerticalSpacing) {
        if !isLabelDisabled {
          FieldSmallLabel(label)
            .style(mood: .neutral, intensity: .supershy)
        }
        ViewThatFits {
          content
            .lineLimit(1)
          content
            .onAppear { isLabelOverflowing = true }
        }
        .labelStyle(.displayFieldGenericText)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.trailing, contentTrailingSpacing)

      if isEnabled {
        FieldActionsStack {
          actions
        }
        .tint(.fieldTintColor(for: .brand))
        .transformEnvironment(\.style) { style in
          style = .init(mood: .brand, intensity: .quiet, priority: .high)
        }
      }
    }
    .listRowInsets(
      .field(
        isLabelVisible: !isLabelDisabled,
        hasActions: hasActions
      )
    )
    .tint(.fieldTintColor(for: mood))
    .frame(
      minHeight: minimumHeight
        - (EdgeInsets.field(
          isLabelVisible: !isLabelDisabled,
          hasActions: hasActions
        )?.vertical ?? 0)
    )
    .transformEnvironment(\.style) { style in
      style = Style(mood: style.mood, intensity: .quiet, priority: style.priority)
    }
  }

  private var hasActions: Bool { Actions.self != EmptyView.self }
}

public struct _DisplayFieldTextualPlaceholder: View {
  private let text: String

  init(_ text: String) {
    self.text = text
  }

  public var body: some View {
    Text(verbatim: text)
      .foregroundStyle(Color.ds.text.oddity.disabled)
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

extension EdgeInsets {
  fileprivate static func field(isLabelVisible: Bool, hasActions: Bool) -> EdgeInsets? {
    return EdgeInsets(
      top: isLabelVisible ? 8 : 4,
      leading: 20,
      bottom: isLabelVisible ? 8 : 4,
      trailing: hasActions ? 8 : 20
    )
  }

  fileprivate var vertical: Double { top + bottom }
}

#Preview {
  DisplayFieldPreview()
}
