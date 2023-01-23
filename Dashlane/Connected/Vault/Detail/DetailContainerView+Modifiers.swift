import SwiftUI

struct DetailContainerViewSpecificDismissKey: EnvironmentKey {
    static var defaultValue: DetailContainerViewSpecificAction?
}

struct DetailContainerViewSpecificSaveKey: EnvironmentKey {
    static var defaultValue: DetailContainerViewSpecificAction?
}

enum SpecificBackButton {
    case close
    case back
}

struct DetailContainerViewSpecificBackButtonKey: EnvironmentKey {
    static var defaultValue: SpecificBackButton?
}

extension EnvironmentValues {
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

extension View {
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

struct DetailContainerViewSpecificAction {
    private let action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
    }

    func callAsFunction() {
        action()
    }
}
