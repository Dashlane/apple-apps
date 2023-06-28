import SwiftUI

struct DetailContainerViewSpecificDismissKey: EnvironmentKey {
    static var defaultValue: DetailContainerViewSpecificAction?
}

struct DetailContainerViewSpecificSaveKey: EnvironmentKey {
    static var defaultValue: DetailContainerViewSpecificAction?
}

public enum SpecificBackButton {
    case close
    case back
}

struct DetailContainerViewSpecificBackButtonKey: EnvironmentKey {
    static var defaultValue: SpecificBackButton?
}

public extension EnvironmentValues {
    var detailContainerViewSpecificDismiss: DetailContainerViewSpecificAction? {
        get { self[DetailContainerViewSpecificDismissKey.self] }
        set { self[DetailContainerViewSpecificDismissKey.self] = newValue }
    }

    var detailContainerViewSpecificSave: DetailContainerViewSpecificAction? {
        get { self[DetailContainerViewSpecificSaveKey.self] }
        set { self[DetailContainerViewSpecificSaveKey.self] = newValue }
    }

    var detailContainerViewSpecificBackButton: SpecificBackButton? {
        get { self[DetailContainerViewSpecificBackButtonKey.self] }
        set { self[DetailContainerViewSpecificBackButtonKey.self] = newValue }
    }
}

public extension View {
            func detailContainerViewSpecificDismiss(_ dismiss: DetailContainerViewSpecificAction?) -> some View {
        self.environment(\.detailContainerViewSpecificDismiss, dismiss)
    }

            func detailContainerViewSpecificSave(_ save: DetailContainerViewSpecificAction) -> some View {
        self.environment(\.detailContainerViewSpecificSave, save)
    }

            func detailContainerViewSpecificBackButton(_ type: SpecificBackButton) -> some View {
        self.environment(\.detailContainerViewSpecificBackButton, type)
    }
}

public struct DetailContainerViewSpecificAction {
    private let action: () -> Void

    public init(_ action: @escaping () -> Void) {
        self.action = action
    }

    public func callAsFunction() {
        action()
    }
}
