import SwiftUI

enum PreviewedModifier {
  case mood([Mood])
  case intensity([Intensity])
  case controlSize([ControlSize])

  static var mood = PreviewedModifier.mood(Mood.allCases)
  static var intensity = PreviewedModifier.intensity(Intensity.allCases)
  static var controlSize = PreviewedModifier.controlSize([
    .mini, .small, .regular, .large, .extraLarge,
  ])
}

extension PreviewedModifier {
  @ViewBuilder
  func forEach(@ViewBuilder block: @escaping (String) -> some View) -> some View {
    switch self {
    case let .controlSize(controlSizes):
      ForEach(controlSizes, id: \.self) { (size: ControlSize) in
        block(String(describing: size))
          .controlSize(size)
      }

    case let .mood(moods):
      ForEach(moods) { mood in
        block(mood.rawValue)
          .style(mood: mood)
      }

    case let .intensity(intensities):
      ForEach(intensities) { intensity in
        block(intensity.rawValue)
          .style(intensity: intensity)
      }
    }
  }
}
