import SwiftUI
import DesignSystem

public struct NavigationBarButton<Label: View>: View {

    public enum Style {
        case `default`

        var color: Color {
            switch self {
            case .default: return .ds.text.neutral.standard
            }
        }
    }

    let action: () -> Void
    let label: () -> Label
    let style: Style

    public init(action: @escaping () -> Void,
                @ViewBuilder label: @escaping () -> Label,
                style: Style = .default) {
        self.action = action
        self.label = label
        self.style = style
    }

    public init(action: @escaping () -> Void,
                label: Label,
                style: Style = .default) {
        self.action = action
        self.style = style
        self.label = { label }
    }

    public var body: some View {
        Button(action: action, label: label)
            .buttonStyle(ColoredButtonStyle(color: style.color))
    }
}

public extension NavigationBarButton where Label == Text {

    init<S: StringProtocol>(_ title: S,
                            action: @escaping () -> Void,
                            style: Style = .default) {
        self.init(action: action, label: Text(title), style: style)
    }

    init<S: StringProtocol>(action: @escaping () -> Void,
                            title: S,
                            style: Style = .default) {
        self.init(action: action, label: Text(title), style: style)
    }
}

struct NavigationBarButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarButton(action: {}, label: {Text("Button")})
    }
}
