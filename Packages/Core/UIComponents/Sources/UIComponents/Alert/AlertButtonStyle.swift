#if canImport(UIKit)
import SwiftUI
import UIDelight
import DesignSystem

public struct AlertButtonStyle: ButtonStyle {

    var mainButton: Bool

    public init(mainButton: Bool = true) {
        self.mainButton = mainButton
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: mainButton ? .semibold : .regular, design: .default))
            .foregroundColor(configuration.isPressed ? .ds.text.brand.standard.opacity(0.8) : .ds.text.brand.standard)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.gray.opacity(0.001)) 
    }
}

struct AlertButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            Text("This is an alert")
                .padding()
            Divider()
            Button("hello", action: { })
                .buttonStyle(AlertButtonStyle())
        }.modifier(AlertStyle())
        .backgroundColorIgnoringSafeArea(Color(white: 0.0, opacity: 0.2))
    }
}
#endif
