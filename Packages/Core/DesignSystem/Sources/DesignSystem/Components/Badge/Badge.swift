import SwiftUI

public struct Badge: View {
    @Environment(\.style) private var style
    @Environment(\.iconAlignment) private var iconAlignment

    @ScaledMetric private var iconDimension = 12
    @ScaledMetric private var backgroundCornerRadius = 2
    @ScaledMetric private var textHorizontalPadding = 2
    @ScaledMetric private var containerPadding = 4

    private let title: String
    private let icon: Image?

                    public init(_ title: String, icon: Image? = nil) {
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: 0) {
            if let icon, iconAlignment == .leading {
                makeIconView(icon: icon)
            }
            Text(title)
                .textStyle(.component.badge.standard)
                .lineLimit(1)
                .foregroundColor(.labelColor(for: style))
                .padding(.horizontal, textHorizontalPadding)
            if let icon, iconAlignment == .trailing {
                makeIconView(icon: icon)
            }
        }
        .padding(containerPadding)
        .background(backgroundView)
        .accessibilityElement()
        .accessibilityLabel(Text(title))
    }

    @ViewBuilder
    private var backgroundView: some View {
        if let borderColor = Color.borderColor(for: style) {
            RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        } else {
            RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
                .foregroundColor(.backgroundColor(for: style))
        }
    }

    private func makeIconView(icon: Image) -> some View {
        icon
            .resizable()
            .frame(width: iconDimension, height: iconDimension)
            .foregroundColor(.labelColor(for: style))
    }
}

private extension Color {

    static func backgroundColor(for style: Style) -> Color {
        switch style.mood {
        case .neutral:
            switch style.intensity {
            case .catchy:
                return .ds.container.expressive.neutral.catchy.idle
            case .quiet:
                return .ds.container.expressive.neutral.quiet.idle
            case .supershy:
                return .clear
            }
        case .brand:
            switch style.intensity {
            case .catchy:
                return .ds.container.expressive.brand.catchy.idle
            case .quiet:
                return .ds.container.expressive.brand.quiet.idle
            case .supershy:
                return .clear
            }
        case .danger:
            switch style.intensity {
            case .catchy:
                return .ds.container.expressive.danger.catchy.idle
            case .quiet:
                return .ds.container.expressive.danger.quiet.idle
            case .supershy:
                return .clear
            }
        case .positive:
            switch style.intensity {
            case .catchy:
                return .ds.container.expressive.positive.catchy.idle
            case .quiet:
                return .ds.container.expressive.positive.quiet.idle
            case .supershy:
                return .clear
            }
        case .warning:
            switch style.intensity {
            case .catchy:
                return .ds.container.expressive.warning.catchy.idle
            case .quiet:
                return .ds.container.expressive.warning.quiet.idle
            case .supershy:
                return .clear
            }
        }
    }

    static func borderColor(for style: Style) -> Color? {
        guard case .supershy = style.intensity else { return nil }
        switch style.mood {
        case .neutral:
            return .ds.border.neutral.quiet.idle
        case .brand:
            return .ds.border.brand.quiet.idle
        case .danger:
            return .ds.border.danger.quiet.idle
        case .positive:
            return .ds.border.positive.quiet.idle
        case .warning:
            return .ds.border.warning.quiet.idle
        }
    }

    static func labelColor(for style: Style) -> Color {
        switch style.mood {
        case .neutral:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            default:
                return .ds.text.neutral.standard
            }
        case .brand:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            default:
                return .ds.text.brand.standard
            }
        case .danger:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            default:
                return .ds.text.danger.standard
            }
        case .positive:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            default:
                return .ds.text.positive.standard
            }
        case .warning:
            switch style.intensity {
            case .catchy:
                return .ds.text.inverse.catchy
            default:
                return .ds.text.warning.standard
            }
        }
    }
}

struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        BadgePreview()
    }
}
