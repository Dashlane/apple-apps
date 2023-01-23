import SwiftUI

struct DetailRowButtonStyle: PrimitiveButtonStyle {
    enum Mode {
        case `default`
        case destructive
        
        var color: Color {
            switch self {
                case .`default`:
                    return Color(asset: FiberAsset.accentColor)
                case .destructive:
                    return .red
            }
        }
    }
    
    let color: Color
    init(_ mode: Mode = .default) {
        self.color = mode.color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        #if targetEnvironment(macCatalyst)
        let buttonStyle = BorderlessButtonStyle() 
        #else
        let buttonStyle = DefaultButtonStyle() 
        #endif
        
        Button(action: configuration.trigger) {
            configuration.label
                .foregroundColor(color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(buttonStyle)
    }
}
