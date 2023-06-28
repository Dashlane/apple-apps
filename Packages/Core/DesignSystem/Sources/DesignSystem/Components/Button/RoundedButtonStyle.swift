import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    @Environment(\.style)
    private var style

    @Environment(\.roundedButtonLayout)
    private var layout

    @Environment(\.isEnabled)
    private var isEnabled

    @ScaledMetric
    private var cornerRadius = 10

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .textStyle(.component.button.standard)
        #if targetEnvironment(macCatalyst)
            .tintColor(.tint(for: style, isEnabled: isEnabled))
        #else
            .accentColor(.tint(for: style, isEnabled: isEnabled))
        #endif
            .frame(maxWidth: layout == .fill ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.background(
                        for: style,
                        isPressed: configuration.isPressed,
                        isEnabled: isEnabled)
                    )
            )
    }
}

struct RoundedButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        StylesButtonPreview()
    }
}

private extension Color {
    static func background(for style: Style, isPressed: Bool, isEnabled: Bool) -> Color {
        switch style.mood {
        case .neutral:
            switch style.intensity {
            case .catchy:
                guard isEnabled else { return .ds.container.expressive.neutral.catchy.disabled }
                return isPressed
                ? .ds.container.expressive.neutral.catchy.active
                : .ds.container.expressive.neutral.catchy.idle
            case .quiet:
                guard isEnabled else { return .ds.container.expressive.neutral.quiet.disabled }
                return isPressed
                ? .ds.container.expressive.neutral.quiet.active
                : .ds.container.expressive.neutral.quiet.idle
            case .supershy:
                guard isEnabled else {
                    return background(
                        for: .init(mood: .neutral, intensity: .quiet),
                        isPressed: false,
                        isEnabled: false
                    )
                }
                return background(
                    for: .init(mood: .neutral, intensity: .quiet),
                    isPressed: true,
                    isEnabled: isEnabled
                )
                .opacity(isPressed ? 1 : 0)
            }
        case .brand:
            switch style.intensity {
            case .catchy:
                guard isEnabled else { return .ds.container.expressive.brand.catchy.disabled }
                return isPressed
                ? .ds.container.expressive.brand.catchy.active
                : .ds.container.expressive.brand.catchy.idle
            case .quiet:
                guard isEnabled else { return .ds.container.expressive.brand.quiet.disabled }
                return isPressed
                ? .ds.container.expressive.brand.quiet.active
                : .ds.container.expressive.brand.quiet.idle
            case .supershy:
                guard isEnabled else {
                    return background(
                        for: .init(mood: .brand, intensity: .quiet),
                        isPressed: false,
                        isEnabled: false
                    )
                }
                return background(
                    for: .init(mood: .brand, intensity: .quiet),
                    isPressed: true,
                    isEnabled: isEnabled
                )
                .opacity(isPressed ? 1 : 0)
            }
        case .warning:
            switch style.intensity {
            case .catchy:
                guard isEnabled else { return .ds.container.expressive.warning.catchy.disabled }
                return isPressed
                ? .ds.container.expressive.warning.catchy.active
                : .ds.container.expressive.warning.catchy.idle
            case .quiet:
                guard isEnabled else { return .ds.container.expressive.warning.quiet.disabled }
                return isPressed
                ? .ds.container.expressive.warning.quiet.active
                : .ds.container.expressive.warning.quiet.idle
            case .supershy:
                guard isEnabled else {
                    return background(
                        for: .init(mood: .warning, intensity: .quiet),
                        isPressed: false,
                        isEnabled: false
                    )
                }
                return background(
                    for: .init(mood: .warning, intensity: .quiet),
                    isPressed: true,
                    isEnabled: isEnabled
                )
                .opacity(isPressed ? 1 : 0)
            }
        case .danger:
            switch style.intensity {
            case .catchy:
                guard isEnabled else { return .ds.container.expressive.danger.catchy.disabled }
                return isPressed
                ? .ds.container.expressive.danger.catchy.active
                : .ds.container.expressive.danger.catchy.idle
            case .quiet:
                guard isEnabled else { return .ds.container.expressive.danger.quiet.disabled }
                return isPressed
                ? .ds.container.expressive.danger.quiet.active
                : .ds.container.expressive.danger.quiet.idle
            case .supershy:
                guard isEnabled else {
                    return background(
                        for: .init(mood: .danger, intensity: .quiet),
                        isPressed: false,
                        isEnabled: false
                    )
                }
                return background(
                    for: .init(mood: .danger, intensity: .quiet),
                    isPressed: true,
                    isEnabled: isEnabled
                )
                .opacity(isPressed ? 1 : 0)
            }
        case .positive:
            switch style.intensity {
            case .catchy:
                guard isEnabled else { return .ds.container.expressive.positive.catchy.disabled }
                return isPressed
                ? .ds.container.expressive.positive.catchy.active
                : .ds.container.expressive.positive.catchy.idle
            case .quiet:
                guard isEnabled else { return .ds.container.expressive.positive.quiet.disabled }
                return isPressed
                ? .ds.container.expressive.positive.quiet.active
                : .ds.container.expressive.positive.quiet.idle
            case .supershy:
                guard isEnabled else {
                    return background(
                        for: .init(mood: .positive, intensity: .quiet),
                        isPressed: false,
                        isEnabled: false
                    )
                }
                return background(
                    for: .init(mood: .positive, intensity: .quiet),
                    isPressed: true,
                    isEnabled: isEnabled
                )
                .opacity(isPressed ? 1 : 0)
            }
        }
    }

    static func tint(for style: Style, isEnabled: Bool) -> Color {
        guard isEnabled else { return .ds.text.oddity.disabled }
        switch style.mood {
        case .neutral:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            case .quiet, .supershy:
                return .ds.text.neutral.standard
            }
        case .brand:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            case .quiet, .supershy:
                return .ds.text.brand.standard
            }
        case .warning:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            case .quiet, .supershy:
                return .ds.text.warning.standard
            }
        case .danger:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            case .quiet, .supershy:
                return .ds.text.danger.standard
            }
        case .positive:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            case .quiet, .supershy:
                return .ds.text.positive.standard
            }
        }
    }
}
