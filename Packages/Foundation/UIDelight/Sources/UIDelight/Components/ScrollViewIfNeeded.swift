import SwiftUI

public struct ScrollViewIfNeeded<Content: View>: View {

    @State
    private var shouldScroll: Bool = false

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            content
                .frame(maxWidth: .infinity)
                .background(
                    GeometryReader { contentGeometry in
                        Color.clear.onAppear {
                            shouldScroll = contentGeometry.size.height > geometry.size.height
                        }
                    }
                )
                .shouldWrapInScrollView(shouldScroll)
        }
    }
}

extension View {
    @ViewBuilder
    fileprivate func shouldWrapInScrollView(_ condition: Bool) -> some View {
        if condition {
            ScrollView {
                self
            }
        } else {
            self
        }
    }
}
