import SwiftUI

struct HoverableViewModifier: ViewModifier {
    
    let padding: CGFloat
    let borderColor: Color
    
    @State
    private var hovered: Bool = false
    
    init(padding: CGFloat = 4,
         borderColor: Color = Color(asset: Asset.separation)) {
        self.padding = padding
        self.borderColor = borderColor
    }
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(hovered ? borderColor : Color.clear, lineWidth: 1)
            )
            .onHover(perform: { hovering in
                self.hovered = hovering
            })
    }
}

extension View {
    func hoverable() -> some View {
        self.modifier(HoverableViewModifier())
    }
}
