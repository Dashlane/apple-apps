import Foundation
import SwiftUI

struct DashlaneDefaultButtonStyle: ButtonStyle {
    
    var backgroundColor = Color(asset: Asset.buttonBackground)
    var borderColor = Color(asset: Asset.buttonBackground)
    var foregroundColor = Color.white
    let radius: CGFloat = 6
    var shouldTakeAllWidth: Bool = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: shouldTakeAllWidth ? .infinity : nil, maxHeight: .infinity)
            .background(configuration.isPressed ? backgroundColor.colorWithSystemEffect(.pressed) : backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(radius)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(borderColor, lineWidth: 1)
            )
            
            
    }
}
