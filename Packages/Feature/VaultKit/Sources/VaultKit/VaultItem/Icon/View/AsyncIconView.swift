import SwiftUI
import IconLibrary
import UIDelight

public struct AsyncIconView<Placeholder: View, IconView: View>: View {
    let animate: Bool
    let provider: @Sendable () async throws -> Icon?
    let placeholder: Placeholder
    let content: (SwiftUI.Image, IconColorSet?) -> IconView
    
    @State
    var icon: Icon?
    
    public init(animate: Bool = true,
         provider: @Sendable @escaping () async throws -> Icon?,
         @ViewBuilder content: @escaping (SwiftUI.Image, IconColorSet?) -> IconView,
         @ViewBuilder placeholder: () -> Placeholder) {
        self.animate = animate
        self.provider = provider
        self.content = content
        self.placeholder = placeholder()
    }
    
    public var body: some View {
        ZStack {
            if let icon = icon, let image = icon.image  {
                content(Image(appImage: image), icon.colors)
            } else {
                placeholder
            }
        }
        .animationIfNeeded(animate: animate, animation: .easeOut(duration: 0.2), value: icon)
        .task {
            icon = try? await provider()
        }
    }
}

private extension View {
    
                @ViewBuilder
    func animationIfNeeded<Value: Equatable>(animate: Bool,
                                                animation: Animation,
                                                value: Value) -> some View {
        if animate {
            self.animation(animation, value: value)
        } else {
            self
        }
    }
}

struct AsyncIconView_Previews: PreviewProvider {
    static let placeholder = Text("placeholder")
    static var previews: some View {
        Group {
            AsyncIconView {
                Icon(image: Asset.logomark.image)
            } content: { image, colors in
                image
                    .resizable()
            } placeholder: {
                placeholder
            }
            .previewDisplayName("Image")
        
            AsyncIconView{
                let colors = IconColorSet(backgroundColor: .red, mainColor: .red, fallbackColor: .red)
                return Icon(image: Asset.logomark.image, colors: colors)
            } content: { image, colors in
                let color = colors?.backgroundColor
                
                image
                    .resizable()
                    .background(color.map { Color($0) })
            }placeholder: {
                placeholder
            }
            .previewDisplayName("Background Colors")
            
            AsyncIconView {
                return nil
            } content: { image, colors in
                image
                    .resizable()
            } placeholder: {
                placeholder
            }
            .previewDisplayName("Placeholder")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
