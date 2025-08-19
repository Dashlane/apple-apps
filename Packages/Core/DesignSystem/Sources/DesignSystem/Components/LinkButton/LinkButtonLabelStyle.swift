import Foundation
import SwiftUI

struct LinkButtonLabelStyle: LabelStyle {
  @Environment(\.self) private var environment
  @ScaledMetric private var spacing = 4

  func makeBody(configuration: Configuration) -> some View {
    HStack(alignment: .center, spacing: spacing) {
      configuration.title
        .multilineTextAlignment(.leading)
      configuration.icon
    }
    .textStyle(.linkButtonLabel(in: environment))
    .foregroundStyle(.ds.text)
    .transformEnvironment(\.style) { style in
      style = Style(mood: style.mood, intensity: .quiet, priority: style.priority)
    }
  }
}

extension LabelStyle where Self == LinkButtonLabelStyle {
  static var link: Self { LinkButtonLabelStyle() }
}

extension TextStyle {
  static func linkButtonLabel(in environment: EnvironmentValues) -> Self {
    if environment.textStyle?.hasReducedTrait == true {
      return .component.link.reduced
    }
    switch environment.controlSize {
    case .mini, .small:
      return .component.link.reduced
    default:
      return .component.link.standard
    }
  }
}

#Preview {
  Label(
    title: { Text("Link") },
    icon: { Image.ds.action.openExternalLink.outlined }
  )
  .labelStyle(.link)
  .padding()
}
