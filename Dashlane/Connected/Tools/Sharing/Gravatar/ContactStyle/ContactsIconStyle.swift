import DesignSystem
import Foundation
import SwiftUI

struct ContactsIconStyle: ViewModifier {
    let shape: Circle
    let backgroundColor: Color
    let isLarge: Bool

    var size: CGSize {
        isLarge ? CGSize(width: 72, height: 72) : CGSize(width: 42, height: 42)
    }

    init(backgroundColor: Color? = nil, isLarge: Bool) {
        shape = Circle()
        self.backgroundColor = backgroundColor ?? .ds.container.agnostic.neutral.quiet
        self.isLarge = isLarge
    }

    func body(content: Content) -> some View {
        backgroundColor
            .overlay {
                                content
                    .frame(width: size.width, height: size.height)
            }
            .frame(width: size.width, height: size.height)
            .background(backgroundColor)
            .clipShape(shape)
    }
}

extension View {
    func contactsIconStyle(isLarge: Bool, backgroundColor: Color? = nil) -> some View {
        self.modifier(ContactsIconStyle(backgroundColor: backgroundColor, isLarge: isLarge))
    }
}

struct ContactsIconStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Rectangle()
                .foregroundColor(.red)
                .contactsIconStyle(isLarge: false)
            Text("He")
                .foregroundColor(.red)
                .contactsIconStyle(isLarge: true)
            Text("He")
                .foregroundColor(.red)
                .contactsIconStyle(isLarge: false)
        }.previewLayout(.sizeThatFits)
    }
}
