import Foundation
import SwiftUI

struct SearchViewHeaderHeightKey: EnvironmentKey {
    static var defaultValue: CGFloat = 0
}

struct SearchViewFiltersViewKey: EnvironmentKey {
    static var defaultValue: AnyView?
}

extension EnvironmentValues {
    var searchHeaderHeight: CGFloat {
        get { self[SearchViewHeaderHeightKey.self] }
        set { self[SearchViewHeaderHeightKey.self] = newValue }
    }

    var searchFiltersView: AnyView? {
        get { self[SearchViewFiltersViewKey.self] }
        set { self[SearchViewFiltersViewKey.self] = newValue }
    }
}

extension View {
            func searchHeaderHeight(_ height: CGFloat) -> some View {
        self.environment(\.searchHeaderHeight, height)
    }

                    func searchFiltersView(_ filtersView: some View) -> some View {
        self.environment(\.searchFiltersView, filtersView.eraseToAnyView())
    }
}
