import DesignSystem
import SwiftUI

struct ButtonsView: View {
  enum ViewConfiguration: String, CaseIterable {
    case standardConfigurations
    case appearancesLight
    case appearancesDark
    case smallestDynamicTypeClass
    case largestDynamicTypeClass
  }

  var viewConfiguration: ViewConfiguration? {
    guard let configuration = ProcessInfo.processInfo.environment["buttonsConfiguration"]
    else { return nil }
    return ViewConfiguration(rawValue: configuration)
  }

  var body: some View {
    switch viewConfiguration {
    case .standardConfigurations:
      standardConfigurations
    case .appearancesLight:
      appearancesGrid
        .colorScheme(.light)
    case .appearancesDark:
      appearancesGrid
        .colorScheme(.dark)
    case .smallestDynamicTypeClass:
      standardConfigurations
        .environment(\.sizeCategory, .extraSmall)
    case .largestDynamicTypeClass:
      standardConfigurations
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    case .none:
      EmptyView()
    }
  }

  private var standardConfigurations: some View {
    VStack(spacing: 20) {
      ForEach([ControlSize.small, .regular], id: \.self) { controlSize in
        VStack {
          Button(
            action: {},
            label: { Label(icon: Image("infobox")) }
          )
          .buttonStyle(.designSystem(.iconOnly))
          .accessibilityLabel("Infobox \(controlSize.description)")
          .controlSize(controlSize)

          Button(
            action: {},
            label: {
              Label(
                title: { Text(verbatim: "Primary \(controlSize)") },
                icon: { EmptyView() }
              )
            }
          )
          .buttonStyle(.designSystem(.titleOnly))
          .controlSize(controlSize)

          Button(
            action: {},
            label: {
              Label(
                title: { Text(verbatim: "Primary \(controlSize) with glyph") },
                icon: { Image("infobox").resizable() }
              )
            }
          )
          .buttonStyle(.designSystem(.iconLeading))
          .controlSize(controlSize)
        }
      }
    }
  }

  private var appearancesGrid: some View {
    VStack(spacing: 8) {
      ForEach(Array(Mood.allCases.enumerated()), id: \.offset) { index, mood in
        HStack(spacing: 20) {
          VStack {
            ForEach(Array(Intensity.allCases.enumerated()), id: \.offset) { xIndex, intensity in
              Button(
                action: {},
                label: {
                  Label(
                    title: { Text(verbatim: "Title \(xIndex + index * Intensity.allCases.count)") },
                    icon: { Image("infobox").resizable() }
                  )
                }
              )
              .buttonStyle(.designSystem(.iconLeading))
              .style(mood: mood, intensity: intensity)
            }
          }
          VStack {
            ForEach(Array(Intensity.allCases.enumerated()), id: \.offset) { yIndex, intensity in
              Button(
                action: {},
                label: {
                  Label(
                    title: {
                      Text(
                        verbatim:
                          "Title \(yIndex + index * Intensity.allCases.count + numberOfAppearances)"
                      )
                    },
                    icon: { Image("infobox").resizable() }
                  )
                }
              )
              .buttonStyle(.designSystem(.iconLeading))
              .style(mood: mood, intensity: intensity)
            }
          }
          .disabled(true)
        }
      }
    }
    .backgroundColorIgnoringSafeArea(Color.ds.background.alternate)
  }

  private var numberOfAppearances: Int {
    Intensity.allCases.count * Mood.allCases.count
  }
}

struct ButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    ButtonsView()
      .ignoresSafeArea()
      .previewDevice("iPhone 13 Pro")
  }
}

extension ControlSize: CustomStringConvertible {

  public var description: String {
    switch self {
    case .mini:
      return "mini"
    case .small:
      return "small"
    case .regular:
      return "regular"
    case .large:
      return "large"
    case .extraLarge:
      return "extraLarge"
    }
  }
}
