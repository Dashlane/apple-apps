import Foundation
import SwiftUI

struct DividerAdderModifier: ViewModifier {

    var isActivated: Bool
    var height: CGFloat

    init(isActivated: Bool, height: CGFloat) {
        self.isActivated = isActivated
        self.height = height
    }

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if isActivated {
                Divider()
                    .padding(.horizontal, 10)
            }
            content
            if isActivated {
                Divider()
                    .padding(.horizontal, 10)
            }
        }
        .frame(height: height)
    }
}

extension View {
    func dividerAdder(isActivated: Bool, height: CGFloat = 61) -> some View {
        self.modifier(DividerAdderModifier(isActivated: isActivated, height: height))
    }
}
