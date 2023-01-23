import SwiftUI

struct RowActionButtonStyle: ButtonStyle {
    
    let enabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        if enabled {
            base(configuration: configuration)
                .foregroundColor(Color(asset: Asset.primaryHighlight))
                .hoverable()
        } else {
            base(configuration: configuration)
                .foregroundColor(Color(NSColor.disabledControlTextColor))
                .disabled(true)
        }
    }
    
    func base(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(LightButtonStyle())
    }
}
