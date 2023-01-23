import SwiftUI

public enum RoundedButtonLayout {
    case fit
    case fill
}

struct RoundedButtonLayoutKey: EnvironmentKey {
    static var defaultValue = RoundedButtonLayout.fit
}

extension EnvironmentValues {
    var roundedButtonLayout: RoundedButtonLayout {
        get { self[RoundedButtonLayoutKey.self] }
        set { self[RoundedButtonLayoutKey.self] = newValue }
    }
}

public extension View {
            func roundedButtonLayout(_ layout: RoundedButtonLayout) -> some View {
        self.environment(\.roundedButtonLayout, layout)
    }
}

struct RoundedButtonLayout_Library: LibraryContentProvider {

    @LibraryContentBuilder
    func modifiers(base: some View) -> [LibraryItem] {
        LibraryItem(
            base.roundedButtonLayout(.fill),
            title: "Rounded Button Layout",
            category: .effect
        )
    }
}
