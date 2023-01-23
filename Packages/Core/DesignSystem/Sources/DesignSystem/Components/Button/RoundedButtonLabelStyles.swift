import SwiftUI

struct RoundedButtonIconOnlyLabelStyle: LabelStyle {
    @ScaledMetric private var iconDimension = 16
    @ScaledMetric private var contentScale = 100

    @Environment(\.controlSize) private var controlSize
    @Environment(\.tintColor) private var tintColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.icon
            .foregroundColor(tintColor ?? .accentColor)
            .frame(width: iconDimension, height: iconDimension)
            .padding(.all, padding * effectiveContentScale)
    }

    private var padding: Double {
        switch controlSize {
        case .mini, .small:
            return 12
        case .regular, .large:
            fallthrough
        @unknown default:
            return 16
        }
    }

    private var effectiveContentScale: Double {
        contentScale / 100
    }
}

struct RoundedButtonTitleOnlyLabelStyle: LabelStyle {
    @Environment(\.controlSize) private var controlSize
    @Environment(\.tintColor) private var tintColor

    @ScaledMetric private var contentScale = 100

    func makeBody(configuration: Configuration) -> some View {
        configuration.title
            .foregroundColor(tintColor ?? .accentColor)
            .font(.system(.body).weight(.medium))
            .padding(padding)
    }

    private var padding: EdgeInsets {
        switch controlSize {
        case .mini, .small:
            return EdgeInsets(
                top: 10 * effectiveContentScale,
                leading: 14 * effectiveContentScale,
                bottom: 10 * effectiveContentScale,
                trailing: 14 * effectiveContentScale
            )
        case .regular, .large:
            fallthrough
        @unknown default:
            return EdgeInsets(
                top: 14 * effectiveContentScale,
                leading: 18 * effectiveContentScale,
                bottom: 14 * effectiveContentScale,
                trailing: 18 * effectiveContentScale
            )
        }
    }

    private var effectiveContentScale: Double {
        contentScale / 100
    }
}

struct RoundedButtonTitleAndIconLabelStyle: LabelStyle {
    @Environment(\.iconAlignment) private var iconAlignment
    @Environment(\.controlSize) private var controlSize
    @Environment(\.tintColor) private var tintColor

    @ScaledMetric private var iconDimension = 16
    @ScaledMetric private var contentScale = 100

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 8 * effectiveContentScale) {
            if iconAlignment == .leading {
                iconView(for: configuration)
            }
            configuration.title
                .foregroundColor(tintColor ?? .accentColor)
                .font(.system(.body).weight(.medium))
            if iconAlignment == .trailing {
                iconView(for: configuration)
            }
        }
        .foregroundColor(tintColor ?? .accentColor)
        .padding(padding)
    }

    private func iconView(for configuration: Configuration) -> some View {
        configuration.icon
            .frame(width: iconDimension, height: iconDimension)
    }

    private var padding: EdgeInsets {
        switch controlSize {
        case .mini, .small:
            return EdgeInsets(
                top: 10 * effectiveContentScale,
                leading: 14 * effectiveContentScale,
                bottom: 10 * effectiveContentScale,
                trailing: 14 * effectiveContentScale
            )
        case .regular, .large:
            fallthrough
        @unknown default:
            return EdgeInsets(
                top: 14 * effectiveContentScale,
                leading: 18 * effectiveContentScale,
                bottom: 14 * effectiveContentScale,
                trailing: 18 * effectiveContentScale
            )
        }
    }

    private var effectiveContentScale: Double {
        contentScale / 100
    }
}
