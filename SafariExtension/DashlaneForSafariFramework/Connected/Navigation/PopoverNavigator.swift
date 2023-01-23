import Foundation
import SwiftUI

protocol PopoverNavigator: AnyObject {
    func push<V: View>(_ view: V)
    func popLast()
}

private struct PopoverNavigatorKey: EnvironmentKey {
    static let defaultValue: PopoverNavigator? = nil
}

extension EnvironmentValues {
    var popoverNavigator: PopoverNavigator? {
        get { self[PopoverNavigatorKey.self] }
        set { self[PopoverNavigatorKey.self] = newValue }
    }
}

extension View {
    func navigator(_ navigator: PopoverNavigator?) -> some View {
        environment(\.popoverNavigator, navigator)
    }
}
