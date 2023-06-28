import SwiftUI
import CoreLocalization

struct TextFieldActionsStack<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 0) {
            _VariadicView.Tree(TextFieldActionStackLayout()) {
                content
                                                            .buttonStyle(ActionButtonStyle())
            }
            .transition(.scale(scale: 0.5).combined(with: .opacity))
        }
    }
}

private struct ActionButtonStyle: ButtonStyle {
    @Environment(\.tintColor) private var tintColor
    @Environment(\.textFieldFeedbackAppearance) private var feedbackAppearance

    @ScaledMetric private var backgroundPadding = 10
    @ScaledMetric private var backgroundCornerRadius = 10

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(effectiveTintColor)
            .background {
                RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
                    .foregroundColor(backgroundColor(for: configuration))
                    .padding(-backgroundPadding)
            }
    }

    private var effectiveTintColor: Color {
        tintColor ?? .accentColor
    }

    private func backgroundColor(for configuration: Configuration) -> Color {
        guard configuration.isPressed else { return .clear }
        if let feedbackAppearance, case .error = feedbackAppearance {
            return .ds.container.expressive.danger.quiet.active
        }
        return .ds.container.expressive.brand.quiet.active
    }
}

private struct TextFieldActionStackLayout: _VariadicView.MultiViewRoot {
    private let maxNumberOfActions = 3

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let shouldMakeMenu = children.count > 3
        let prefix = shouldMakeMenu ? maxNumberOfActions - 1 : children.count

        ForEach(children.prefix(prefix)) { child in
            TextFieldActionContainer {
                child
            }
        }

                if shouldMakeMenu {
            TextFieldActionContainer {
                TextFieldAction.Menu(
                    L10n.Core.moreActionAccessibilityLabel,
                    image: .ds.action.more.outlined
                ) {
                    ForEach(children.suffix(from: maxNumberOfActions - 1)) { child in
                        child
                    }
                }
            }
        }
    }
}

struct TextFieldActionsStack_Previews: PreviewProvider {

    static var previews: some View {
        TextFieldActionsStack {
            TextFieldAction.Button(
                "Password Generator",
                image: .ds.feature.passwordGenerator.outlined,
                action: {}
            )

            TextFieldAction.Button(
                "Open External Link",
                image: .ds.action.openExternalLink.outlined,
                action: {}
            )
        }
    }
}
