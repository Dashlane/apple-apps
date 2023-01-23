import Foundation
import SwiftUI

struct InfoboxButtonStyle: ButtonStyle {

    enum Role {
        case primary
        case secondary
    }

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @Environment(\.style)
    private var style

    @ScaledMetric
    private var cornerRadius: Double = 10
    
    private let role: Role
    
    private var primaryButtonTextColor: Color {
        switch style.mood {
        case .neutral, .brand, .warning, .danger, .positive:
            return .ds.text.inverse.catchy
        }
    }
    
    private var secondaryButtonTextColor: Color {
        switch style.mood {
        case .neutral:
            return .ds.text.neutral.standard
        case .brand:
            return .ds.text.brand.standard
        case .warning:
            return .ds.text.warning.standard
        case .danger:
            return .ds.text.danger.standard
        case .positive:
            return .ds.text.positive.standard
        }
    }
    
    private var primaryButtonBackgroundColor: Color {
        switch style.mood {
        case .neutral:
            return .ds.container.expressive.neutral.catchy.idle
        case .brand:
            return .ds.container.expressive.brand.catchy.idle
        case .warning:
            return .ds.container.expressive.warning.catchy.idle
        case .danger:
            return .ds.container.expressive.danger.catchy.idle
        case .positive:
            return .ds.container.expressive.positive.catchy.idle
        }
    }
    
    private var secondaryButtonBackgroundColor: Color {
        switch style.mood {
        case .neutral:
            return .ds.container.expressive.neutral.quiet.idle
        case .brand:
            return .ds.container.expressive.brand.quiet.idle
        case .warning:
            return .ds.container.expressive.warning.quiet.idle
        case .danger:
            return .ds.container.expressive.danger.quiet.idle
        case .positive:
            return .ds.container.expressive.positive.quiet.idle
        }
    }
    
    private var textColor: Color {
        switch role {
        case .primary:
            return primaryButtonTextColor
        case .secondary:
            return secondaryButtonTextColor
        }
    }
    
    private var backgroundColor: Color {
        switch role {
        case .primary:
            return primaryButtonBackgroundColor
        case .secondary:
            return secondaryButtonBackgroundColor
        }
    }
    
    init(role: InfoboxButtonStyle.Role) {
        self.role = role
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.caption).weight(.medium))
            .foregroundColor(textColor)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            )
            .fixedSize(horizontal: false, vertical: true)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
