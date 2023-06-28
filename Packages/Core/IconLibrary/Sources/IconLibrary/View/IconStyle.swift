import DesignSystem
import SwiftUI

public struct IconStyle: ViewModifier {
    public enum SizeType {
        case large
        case small
        case prefilledCredential
        case safariPopover

        public var size: CGSize {
            switch self {
            case .large:
                return CGSize(width: 86, height: 56)
            case .small:
                return CGSize(width: 56, height: 36)
            case .prefilledCredential:
                return CGSize(width: 70, height: 46)
            case .safariPopover:
                return CGSize(width: 48, height: 32)
            }
        }

        public var radius: CGFloat {
            switch self {
            case .large:
                return 6
            case .small:
                return 4
            case .prefilledCredential:
                return 5
            case .safariPopover:
                return 4
            }
        }
    }

    let shape: RoundedRectangle
    let foregroundColor: SwiftUI.Color
    let backgroundColor: SwiftUI.Color
    let sizeType: SizeType

    init(backgroundColor: SwiftUI.Color? = nil, sizeType: SizeType) {
        shape = RoundedRectangle(cornerRadius: sizeType.radius)
        self.foregroundColor = backgroundColor != nil ? .white : .ds.text.brand.quiet
        self.backgroundColor = backgroundColor ?? .ds.container.agnostic.neutral.standard
        self.sizeType = sizeType
    }

    public func body(content: Content) -> some View {
        backgroundColor
            .overlay {
                                content
                    .foregroundColor(foregroundColor)
            }
            .frame(width: sizeType.size.width, height: sizeType.size.height)
            .clipShape(shape)
            .overlay(border)
    }

    @ViewBuilder
    private var border: some View {
        shape
            .inset(by: 0.5)
            .stroke(SwiftUI.Color.ds.border.neutral.quiet.idle, lineWidth: 1.61)
    }
}

extension View {
    public func iconStyle(sizeType: IconStyle.SizeType, backgroundColor: SwiftUI.Color? = nil) -> some View {
        self.modifier(IconStyle(backgroundColor: backgroundColor, sizeType: sizeType))
    }
}

struct IconStyle_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            Rectangle()
                .foregroundColor(.red)
                .modifier(IconStyle(backgroundColor: .blue,
                                    sizeType: .small))
            Rectangle()
                .foregroundColor(.red)
                .modifier(IconStyle(backgroundColor: .blue,
                                    sizeType: .prefilledCredential))

            Rectangle()
                .foregroundColor(.red)
                .modifier(IconStyle(backgroundColor: .blue,
                                    sizeType: .large))

        }
        .padding()
        .previewLayout(.sizeThatFits)

    }
}
