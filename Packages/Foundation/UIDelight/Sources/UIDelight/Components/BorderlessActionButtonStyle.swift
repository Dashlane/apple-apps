import SwiftUI

public struct BorderlessActionButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17.0, weight: .medium))
            .padding(16.0)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 2.0, style: .continuous))
    }
}
