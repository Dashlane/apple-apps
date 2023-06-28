import Foundation
import SwiftUI

public struct AdaptiveHStack<Content: View>: View {

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let content: (DynamicTypeSize) -> Content
    private let spacing: CGFloat?
    private let verticalAlignment: VerticalAlignment
    private let horizontalAlignment: HorizontalAlignment

    public init(verticalAlignment: VerticalAlignment = .center,
                horizontalAlignment: HorizontalAlignment = .center,
                spacing: CGFloat? = nil,
                @ViewBuilder _ content: @escaping () -> Content) {
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
        self.spacing = spacing
        self.content = { _ in content() }
    }

    public init(verticalAlignment: VerticalAlignment = .center,
                horizontalAlignment: HorizontalAlignment = .center,
                spacing: CGFloat? = nil,
                @ViewBuilder _ content: @escaping (DynamicTypeSize) -> Content) {
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: horizontalAlignment, spacing: spacing) { content(dynamicTypeSize) }
        } else {
            HStack(alignment: verticalAlignment, spacing: spacing) { content(dynamicTypeSize) }
        }
    }
}
