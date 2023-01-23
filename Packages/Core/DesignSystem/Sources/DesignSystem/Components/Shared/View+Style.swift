import SwiftUI

public enum Mood: String, Identifiable, CaseIterable {
    public var id: Self { self }

    case neutral
    case brand
    case warning
    case danger
    case positive
}

public enum Intensity: String, Identifiable, CaseIterable {
    public var id: Self { self }

    case catchy
    case quiet
    case supershy
}

public struct Style {
    let mood: Mood
    let intensity: Intensity
}

struct StyleKey: EnvironmentKey {
    static var defaultValue: Style = .init(mood: .brand, intensity: .catchy)
}

extension EnvironmentValues {
    var style: Style {
        get { self[StyleKey.self] }
        set { self[StyleKey.self] = newValue }
    }
}

public extension View {
                    func style(mood: Mood = .brand, intensity: Intensity = .catchy) -> some View {
        environment(\.style, .init(mood: mood, intensity: intensity))
    }
}
