import SwiftUI

struct RoundedButtonDisplayProgressIndicatorKey: EnvironmentKey {
    static var defaultValue = false
}

extension EnvironmentValues {
    var roundedButtonDisplayProgressIndicator: Bool {
        get { self[RoundedButtonDisplayProgressIndicatorKey.self] }
        set { self[RoundedButtonDisplayProgressIndicatorKey.self] = newValue }
    }
}

public extension View {
            func roundedButtonDisplayProgressIndicator(_ display: Bool) -> some View {
        self.environment(\.roundedButtonDisplayProgressIndicator, display)
    }
}

struct RoundedButtonProgressIndicator_Library: LibraryContentProvider {

    @LibraryContentBuilder
    func modifiers(base: some View) -> [LibraryItem] {
        LibraryItem(
            base.roundedButtonDisplayProgressIndicator(true),
            title: "Rounded Button Progress Indicator",
            category: .effect
        )
    }
}
