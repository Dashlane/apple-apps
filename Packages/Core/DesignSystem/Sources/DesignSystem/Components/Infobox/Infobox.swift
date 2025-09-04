import CoreLocalization
import SwiftUI
import UIDelight

private struct ButtonsStack<Content: View>: View {
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    ViewThatFits(in: .horizontal) {
      HStack(spacing: 8) {
        _VariadicView.Tree(ButtonsStackLayout(reverseOrder: true)) {
          content
        }
      }
      .fixedSize()
      .frame(maxWidth: .infinity, alignment: .trailing)

      VStack(spacing: 8) {
        _VariadicView.Tree(ButtonsStackLayout(reverseOrder: false)) {
          content
        }
      }
    }
  }
}

private struct ButtonsStackLayout: _VariadicView.MultiViewRoot {
  private let maxButtonNumber = 2
  private let reverseOrder: Bool

  init(reverseOrder: Bool) {
    self.reverseOrder = reverseOrder
  }

  func body(children: _VariadicView.Children) -> some View {
    ForEach(
      children.prefix(maxButtonNumber).enumerated().reversed(reverseOrder),
      id: \.offset
    ) { index, child in
      if index == 0 {
        child
          .style(intensity: .catchy, priority: .low)
      } else {
        child
      }
    }
  }
}

public struct Infobox<Buttons: View>: View {
  @Environment(\.controlSize) private var controlSize
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.container) var container

  @ScaledMetric var containerCornerRadius = 12
  @ScaledMetric private var contentScale = 100

  private let buttons: Buttons
  private let description: String?
  private let hasButtons: Bool
  private let title: String

  public init(
    _ title: String,
    description: String? = nil,
    @ViewBuilder buttons: () -> Buttons
  ) {
    self.title = title
    self.description = description
    self.buttons = buttons()
    self.hasButtons = true
  }

  public init(
    _ title: String,
    description: String? = nil
  ) where Buttons == EmptyView {
    self.title = title
    self.description = description
    self.buttons = EmptyView()
    self.hasButtons = false
  }

  public var body: some View {
    ViewThatFits(in: .horizontal) {
      if horizontalSizeClass == .regular {
        HStack(spacing: 16) {
          content
        }
      }
      VStack(spacing: 16) {
        content
      }
    }
    .padding(containerPadding)
    .background(background)
    .listRowInsets(rowInsets)
    .controlSize(effectiveControlSize)
    .transformEnvironment(\.style) { style in
      style = .init(mood: style.mood, intensity: .quiet, priority: .low)
    }
  }

  @ViewBuilder
  private var content: some View {
    Label {
      VStack(alignment: .leading, spacing: 4) {
        titleView
        descriptionView
      }
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)
    } icon: {
      infoIconView
    }
    .labelStyle(.titleAndIcon)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      Text("\(CoreL10n.accessibilityInfoSection): \(title), \(description ?? "")"))

    buttonSection
      .frame(alignment: .trailing)
  }

  private var infoIconView: some View {
    Image.ds.feedback.info.outlined
      .renderingMode(.template)
      .resizable()
      .foregroundStyle(.ds.text)
      .frame(width: iconSize.width, height: iconSize.height)
      .accessibilityHidden(true)
  }

  private var titleView: some View {
    Text(title)
      .textStyle(titleTextStyle)
      .fixedSize(horizontal: false, vertical: true)
      .foregroundStyle(.ds.text)
  }

  @ViewBuilder
  private var descriptionView: some View {
    if let description = description {
      Text(description)
        .textStyle(.body.reduced.regular)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(.ds.text)
    }
  }

  @ViewBuilder
  private var buttonSection: some View {
    if Buttons.self != EmptyView.self {
      ButtonsStack {
        buttons
          .buttonStyle(.designSystem(.titleOnly))
      }
      .controlSize(.small)
    }
  }

  private var effectiveContentScale: Double {
    contentScale / 100
  }

  private var effectiveControlSize: ControlSize {
    guard !hasButtons else { return .large }

    if [.mini, .small].contains(controlSize) {
      return .regular
    }

    return controlSize
  }
}

extension Infobox {
  private var titleTextStyle: TextStyle {
    switch effectiveControlSize {
    case .regular:
      return .title.block.small
    default:
      return .title.block.medium
    }
  }
}

extension Infobox {
  private var containerPadding: Double {
    switch effectiveControlSize {
    case .large:
      return 16
    default:
      return 12
    }
  }

  private var iconSize: CGSize {
    let size: CGSize

    switch effectiveControlSize {
    case .large:
      size = CGSize(width: 20, height: 20)
    default:
      size = CGSize(width: 16, height: 16)
    }

    return size.applying(.init(scaleX: effectiveContentScale, y: effectiveContentScale))
  }
}

extension Sequence {
  fileprivate func reversed(_ reversed: Bool) -> [Self.Element] {
    if reversed {
      self.reversed()
    } else {
      Array(self)
    }
  }
}

#Preview("InfoBox Mood") {
  ModifierPreview(modifier: .mood) {
    Infobox(
      "Title",
      description: "Description"
    ) {
      Button("Primary") {}
      Button("Secondary") {}
    }
  }
}

#Preview("InfoBox Size") {
  ScrollView {
    ModifierPreview(modifier: .controlSize([.regular, .large])) {
      VStack {
        Infobox("A precious bit of information")

        Infobox(
          "A precious bit of information",
          description: "More info about the impact and what to do about it."
        )

        Infobox(
          "A precious bit of information",
          description: "More info about the impact and what to do about it."
        ) {
          Button("Primary") {}
          Button("Secondary") {}
        }
      }
    }
    .style(mood: .brand)
  }
}

#Preview("Standard Configurations") {
  ScrollView {
    VStack {
      Infobox("Title")
      Infobox("Title") {
        Button("Primary") {}
      }

      Infobox("Title") {
        Button("Primary") {}
        Button("Secondary") {}
      }

      Infobox("Title", description: "Description")

      Infobox("Title") {
        Button("Primary Button") {}
        Button("Secondary Button") {}
      }

      Infobox("Title", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.") {
        Button("Primary Button") {}
        Button("Secondary Button") {}
      }

      Infobox("Title", description: "This is the description.") {
        Button(
          action: {},
          label: { Label("Settings", icon: .ds.settings.outlined) }
        )
        .buttonStyle(.designSystem(.iconLeading))
      }

      Infobox("Title", description: "This is the description.") {
        Button(
          action: {},
          label: { Label("Open Settings", icon: .ds.settings.outlined) }
        )
        .buttonStyle(.designSystem(.iconLeading))

        Button("Close") {}
      }
    }
    .padding()
  }
}

#Preview("Button Style Override") {
  VStack {
    Infobox("Title") {
      Button(
        action: {},
        label: { Label("Authenticate", icon: .ds.fingerprint.outlined) }
      )
      .buttonStyle(.designSystem(.iconLeading))
      .style(intensity: .quiet)
    }
    Infobox("Title", description: "Description") {
      Button("Primary Button") {}
        .style(intensity: .quiet)
    }
    .style(mood: .danger)
  }
  .padding()
}
