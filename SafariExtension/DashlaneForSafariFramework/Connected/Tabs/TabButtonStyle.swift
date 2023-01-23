import SwiftUI

struct TabButtonStyle: ButtonStyle {

    let selectedColor = Color(asset: Asset.dashGreenCopy)
    let defaultColor = Color(asset: Asset.nonSelectedTab)
    let isSelected: Bool
    let opacityPressed = 0.3
    let isActive: Bool
    
    func foregroundColor(isPressed: Bool) -> Color {
        if isSelected {
            return isPressed ? selectedColor.colorWithSystemEffect(.pressed) : selectedColor
        } else {
            return isPressed ? defaultColor.colorWithSystemEffect(.pressed) : defaultColor
        }
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor(isPressed: configuration.isPressed))
            .opacity(isActive ? 1: opacityPressed)
    }
}
