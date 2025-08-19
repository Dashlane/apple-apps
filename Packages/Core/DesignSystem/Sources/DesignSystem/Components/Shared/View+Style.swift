import SwiftUI

public enum Mood: String, Identifiable, CaseIterable, Equatable {
  case neutral
  case brand
  case warning
  case danger
  case positive

  public var id: Self { self }
}

public enum Intensity: String, Identifiable, CaseIterable, Equatable {
  case catchy
  case quiet
  case supershy

  public var id: Self { self }
}

public struct Style: Equatable, Comparable, Hashable {
  enum Priority: Int, Equatable {
    case low = 0
    case high
  }

  let mood: Mood
  let intensity: Intensity
  let priority: Priority

  public static func < (lhs: Style, rhs: Style) -> Bool {
    lhs.priority.rawValue < rhs.priority.rawValue
  }
}

extension EnvironmentValues {
  @Entry var style: Style = .init(mood: .brand, intensity: .catchy, priority: .low)
}

extension View {
  func style(
    mood: Mood? = nil,
    intensity: Intensity? = nil,
    priority: Style.Priority
  ) -> some View {
    modifier(
      StyleViewModifier(mood: mood, intensity: intensity, priority: priority)
    )
  }

  public func style(mood: Mood? = nil, intensity: Intensity? = nil) -> some View {
    self.style(mood: mood, intensity: intensity, priority: .high)
  }

  public func style(_ style: Style?) -> some View {
    self.style(mood: style?.mood, intensity: style?.intensity, priority: .high)
  }
}

private struct StyleViewModifier: ViewModifier {
  @Environment(\.style) private var environmentStyle

  private let customMood: Mood?
  private let customIntensity: Intensity?
  private let priority: Style.Priority

  private var style: Style {
    .init(
      mood: customMood ?? environmentStyle.mood,
      intensity: customIntensity ?? environmentStyle.intensity,
      priority: priority
    )
  }

  init(mood: Mood?, intensity: Intensity?, priority: Style.Priority) {
    self.customMood = mood
    self.customIntensity = intensity
    self.priority = priority
  }

  func body(content: Content) -> some View {
    content
      .environment(
        \.style,
        environmentStyle > style ? environmentStyle : style
      )
  }
}
