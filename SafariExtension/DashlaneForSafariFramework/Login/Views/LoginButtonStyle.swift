import SwiftUI

struct LoginButtonStyle: ButtonStyle {
    
    let active: Color = Color(asset: Asset.midGreen)
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 48)
            .foregroundColor(configuration.isPressed ? Color.white.colorWithSystemEffect(.pressed) : Color.white)
            .background(configuration.isPressed ? active.colorWithSystemEffect(.pressed) : active)
            .cornerRadius(10)
    }
    
}
